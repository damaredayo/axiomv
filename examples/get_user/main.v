module main

import damaredayo.axiomv

fn main() {
	// Token, Deployment URL, Org ID.
	// If Deployment URL is blank, it will default to cloud.
	mut client := axiomv.new("TOKEN","","") ?

	// Get self.
	mut user := client.get_current_user() ?
	println(user)
}