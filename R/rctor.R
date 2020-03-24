check_port <- function(port){
  res <- suppressWarnings(
    system(
      paste0(
        "lsof -i -P -n | grep LISTEN | grep :",
        port),
      TRUE))
  return(length(res) > 0)
}

run_tor <- function(
  port = 10000
) {
  
  while(check_port(port)){
    port <- port + 1
  }
  
  container_name <- paste0("tor_",port)
  
  cmd <- paste0("docker run -d --restart=always --name ",
                container_name,
                " -p 127.0.0.1:",
                port,
                ":9150 peterdavehello/tor-socks-proxy:latest")
  
  result <- system(cmd,intern = TRUE)
  
  return(port)
}

rm_tor <- function(port){
  cmd <- paste0("docker rm -f tor_",port)
  system(cmd)
}

get_ip <- function(port){
  
  h <- curl::new_handle(
    proxy = paste0('socks5://127.0.0.1:',port))
  
  ip <- rawToChar(
    curl::curl_fetch_memory(
      "https://ipinfo.tw/ip",
      handle = h)$content)
  
  ip
}

get_contents <- function(
  url,
  sleep = 10){
  port <- run_tor()
  Sys.sleep(sleep)
  h <- curl::new_handle(
    proxy = paste0('socks5://127.0.0.1:',port))
  rawToChar(
    curl::curl_fetch_memory(
      url,
      handle = h)$content)
}




