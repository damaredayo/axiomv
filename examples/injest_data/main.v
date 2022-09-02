module main

import damaredayo.axiomv

fn main() {
	// Token, Deployment URL, Org ID.
	// If Deployment URL is blank, it will default to cloud.
	mut client := axiomv.new("TOKEN","","") ?

	// Injest data into Axiom.
	data := "[{ \"message\": \"Hello World\" }]"

	opts := axiomv.IngestOptions{}

	res := client.ingest("ID", data, axiomv.ContentType.json, axiomv.ContentEncoding.identity, opts) ?
	println(res)

}