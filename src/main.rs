use clap::Parser;
use hyper::{Body, Request, Response, Server};
use hyper::service::{make_service_fn, service_fn};
use std::convert::Infallible;

#[derive(Parser, Debug)]
#[command(author, version, about = "Ping Server", long_about = None)]
struct Args {
    /// Port number to listen on
    #[arg(short, long)]
    port: Option<u16>,
}

async fn handle(_req: Request<Body>) -> Result<Response<Body>, Infallible> {
    // Respond with 200 OK and "OK" in the body
    Ok(Response::new(Body::from("OK\n")))
}

#[tokio::main]
async fn main() {
    let args = Args::parse();

    // Default port is 5555
    let default_port = 5555;

    // Determine the port to use
    let port = args.port.unwrap_or(default_port);

    // Set the address to listen on
    let addr = ([0, 0, 0, 0], port).into();

    // Create the service
    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle))
    });

    // Build the server
    let server = Server::bind(&addr).serve(make_svc);

    // Run the server (no output unless there's an error)
    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }
}
