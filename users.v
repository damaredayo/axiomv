module axiomv

import json

pub struct User {
pub:
	id int [required]
	name string
	emails []string
}

pub fn (mut client Client) get_current_user() ?User {
	resp := client.get(client.deployment_url + "user") or {
		return error("failed to get current user")
	}
	return json.decode(User, resp.body)

}