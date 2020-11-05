use std::env;
use tokio::{time, time::Duration};


fn get_reqwest_test_url() -> String {
    env::var("reqwest_test_url").unwrap_or("".to_string())
}

async fn get_reqwest_test(reqwest_test_url: &String) {
    match reqwest::get(reqwest_test_url).await {
        Ok(res) => {
            println!("reqwest result: {:?}", res);
            let bytes = match res.bytes().await {
                Ok(bytes) => bytes,
                Err(err) => {
                    println!("Failed to get reqwest_test_url bytes from {}", &reqwest_test_url);
                    println!("Error: {}", err);
                    return;
                }
            };
            println!("got bytes from reqwest: {:?}", bytes.to_vec());
        }
        Err(err) => {
            println!("Failed to establish connection to {}", &reqwest_test_url);
            println!("Error: {}", err);
            return;
        }
    };
}

#[tokio::main]
async fn main() {

    let mut tasks = Vec::new();
    tasks.push(tokio::spawn(async move {
        loop {
            time::delay_for(Duration::from_secs(10)).await;

            let reqwest_test_url = get_reqwest_test_url();
            println!("reqwest_test_url: {:?}", &reqwest_test_url);

            get_reqwest_test(&reqwest_test_url).await;
        }
    }));
    futures::future::join_all(tasks).await;
}
