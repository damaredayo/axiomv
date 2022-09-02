module axiomv

import json
import time
import net.http

const timestamp_field = "_time"

pub enum ContentType {
	json = 1
	ndjson
	csv
}

pub enum ContentEncoding {
	identity = 1
	gzip
	zstd
}

pub struct Dataset {
pub:
	id string
	name string
	description string
	created_by string [json: who]
	created_at string [json: created]
}

pub struct TrimResult {
pub:
	blocks_deleted int [json: numDeleted]
}

pub struct IngestFailure {
pub:
	timestamp time.Time
	error string
}

pub struct IngestStatus {
pub:
	ingested u64 [json: ingested]
	failed u64 [json: failed]
	failures []IngestFailure [json: failures]
	processed_bytes u64 [json: processedBytes]
	blocks_created u32 [json: blocksCreated]
	wal_length u32 [json: walLength]
}

pub struct DatasetCreateRequest {
pub:
	name string
	description string
}

pub struct DatasetUpdateRequest {
pub:
	description string
}

struct DatasetTrimRequest {
pub:
	max_duration string [json: maxDuration]
}

struct AplQueryRequest {
pub:
	query string [json: apl]
	start_time time.Time [json: startTime]
	end_time time.Time [json: endTime]
}

pub struct IngestOptions {
pub:
	timestamp_field string
	timestamp_format string
	csv_delimiter string
}

pub fn (mut client Client) list_datasets() ?[]Dataset {
	resp := client.get(client.deployment_url + "datasets") or {
		return error("failed to list datasets")
	}
	return json.decode([]Dataset, resp.body) or {
		return error("failed to decode dataset list")
	}
}

pub fn (mut client Client) get_dataset(id string) ?Dataset {
	resp := client.get(client.deployment_url + "datasets/" + id) or {
		return error("failed to get dataset")
	}
	return json.decode(Dataset, resp.body) or {
		return error("failed to decode dataset")
	}
}

pub fn (mut client Client) create_dataset(req DatasetCreateRequest) ?Dataset {
	resp := client.post(client.deployment_url + "datasets/", json.encode(req)) or {
		return error("failed to create dataset")
	}
	return json.decode(Dataset, resp.body) or {
		return error("failed to decode dataset")
	}
}

pub fn (mut client Client) update_dataset(id string, req DatasetUpdateRequest) ?Dataset {
	resp := client.put(client.deployment_url + "datasets/" + id, json.encode(req)) or {
		return error("failed to update dataset")
	}
	return json.decode(Dataset, resp.body) or {
		return error("failed to decode dataset")
	}
}

pub fn (mut client Client) delete_dataset(id string) ? {
	client.delete(client.deployment_url + "datasets/" + id) or {
		return error("failed to delete dataset")
	}
}

pub fn (mut client Client) trim_dataset(id string, req DatasetTrimRequest) ?TrimResult {
	resp := client.post(client.deployment_url + "datasets/" + id + "/trim", json.encode(req)) or {
		return error("failed to trim dataset")
	}
	return json.decode(TrimResult, resp.body) or {
		return error("failed to decode trim result")
	}
}

pub fn (mut client Client) ingest(id string, data string, typ ContentType, enc ContentEncoding, opts IngestOptions) ?IngestStatus {
	mut path := add_options(client.deployment_url + "datasets/" + id + "/ingest", opts)

	mut req := http.new_request(.post, path, data) or {
		return err
	}

	req.add_header(.authorization, "Bearer $client.access_token")
	req.add_header(.accept, "application/json")
	req.add_header(.content_type, "application/json")
	req.add_header(.user_agent, "axiom-v/0.1.0")

	match typ {
		.json {
			req.add_header(.content_type, "application/json")
		}

		.ndjson {
			req.add_header(.content_type, "application/x-ndjson")
		}

		.csv {
			req.add_header(.content_type, "text/csv")
		}

	}

	match enc {
		.identity {
			// do nothing
		}

		.gzip {
			req.add_header(.content_encoding, "gzip")
		}

		.zstd {
			req.add_header(.content_encoding, "zstd")
		}
	}

	resp := req.do()?

	return json.decode(IngestStatus, resp.body)
}