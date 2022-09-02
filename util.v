module axiomv

import net.urllib

pub fn add_options(s string, options IngestOptions) string {
	mut url := urllib.parse_query(s) or { 
		println("Error parsing url: $s")
		return s
	}

	if options.timestamp_field.len > 0 {
		url.add('timestamp-field', options.timestamp_field)
	}

	if options.timestamp_format.len > 0 {
		url.add('timestamp-format', options.timestamp_format)
	}

	if options.csv_delimiter.len > 0 {
		url.add('csv-delimiter', options.csv_delimiter)
	}

	return s // for now just return the original string, TODO: fix this
}