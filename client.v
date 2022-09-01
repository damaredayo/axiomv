module axiomv

import net.http

const cloud_url = "https://cloud.axiom.co"

[heap]
pub struct Client {
	access_token string [required]
	deployment_url string [required]
	org_id string
}

pub fn new(access_token string, deployment_url string, org_id string) ?&Client {

	mut url := deployment_url

	if url == "" {
		url = cloud_url
	}

	if url[url.len-1] != u8(47) {
		url = "${url}/"
	}

	url = "${url}api/v1/"

	mut client := &Client{
		access_token: access_token,
		deployment_url: url,
		org_id: org_id,
	}

	return client
}

pub fn (mut client Client) get(endpoint string) ?http.Response {
	mut req := http.new_request(.get, client.deployment_url + endpoint, "") or {
		return err
	}

	req.add_header(.authorization, "Bearer $client.access_token")
	req.add_header(.accept, "application/json")
	req.add_header(.content_type, "application/json")
	req.add_header(.user_agent, "axiom-v/0.1.0")

	resp := req.do() ?
	return resp
}