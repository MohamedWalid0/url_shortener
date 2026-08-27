# Installation

```bash
git clone https://github.com/MohamedWalid0/url_shortener
cd url_shortener
docker compose up --build
```
------------------------

# Usage

- Encode

  **Request**
  
  ```bash
  curl -X POST https://web-production-994b4.up.railway.app/api/v1/encode \
    -H 'Content-Type: application/json' \
    -d '{"url":"https://www.google.com/search?q=rails"}'
  ```
  
  **Response**
  
  ```json
  {"id":4,"original_url":"https://www.google.com/search?q=rails","short_url":"https://web-production-994b4.up.railway.app/33a881f5"}
  ```

- Decode
  
  **Request**
  
  ```bash
  curl -X POST https://web-production-994b4.up.railway.app/api/v1/decode \
    -H 'Content-Type: application/json' \
    -d '{"url":"https://web-production-994b4.up.railway.app/33a881f5"}'
  ```
  
  **Response**
  
  ```json
  {"id":4,"original_url":"https://www.google.com/search?q=rails","short_url":"https://web-production-994b4.up.railway.app/33a881f5"}
  ```
------------------------

# Testing

```bash
docker compose exec web bundle exec rspec
```
------------------------

# High Level System design (Current Version) (NOT Scalable)
  <img width="1028" height="498" alt="Screenshot From 2026-08-26 04-23-16" src="https://github.com/user-attachments/assets/3e9c1323-75a8-40a2-b569-79914223f560" />

- Description

  - The app design focuses on simplicity to achieve the task core functionality.
  - The `/encode` endpoint receives the original url, then the flow becomes:
  
  ```
  validate url ->
  call the EncodeUrlService ->
      -> Normalize the url, removing the trailing slashes
      -> Generate the `short_code` using `Digest::SHA1`
      -> Same url gives the same code, so encoding twice is `Idempotent`
      -> On collision, use `Try again Approach`, re-hash with the attempt number, 5 times
  ```
  
  - The `/decode` endpoint receives the short url, then the flow becomes:
  
  ```
  validate url ->
  call the DecodeUrlService ->
      -> Extract the `short_code`
      -> Check if the URL is the same as our host
      -> Find the link by `short_code`, or return not found
  ```
  
  - use `blueprinter` gem, for seralize and unify the `Link` object
  
  # Current Design Tradeoffs
  
  - The app needs Authentication and Authorization, CORS setup 
  - Rate Limiter
  - No CORS setup yet
  - No `GET /:short_code` route yet, so the generated short URLs do not redirect
  
  # Future Scalling requirments (NOT Implemented yet)
  <img width="1175" height="553" alt="Screenshot From 2026-08-26 05-21-15" src="https://github.com/user-attachments/assets/1fa7a493-3578-4417-b8c9-5b55c6138480" />
  
  - Use `Horizontal Scalling` for adding more instances
  - Use `Load Balancer` to distribute the load accross the multiple instances (Simply with `Round-Roben` algorithm)
  - Adding `Rate Lmiter, Authentication, Authorization` to the Api gatway layer
  - Add `Redis` as being `In-Memory DB` layer, to provide fast read opperations using `Read-Through cache` strategy.
  - Adding `DB Replica` to serve reads on a cache miss
  - collision handling at scale
    - While we use `Digest::SHA1` the percentage of expect the firest collision is around 77000 links, and its doesn't scale.
    - even we not cutting first digits and tall the full length it will not be enough and mating the short URLs very long, We have to change the encoding for `Base62` , It will provide collision percentage around 17 million.

------------------------
# AI usage transparency
  
  - Without AI
    ```
      - Solve the problem with my own system design  and coding skills 
      - Design the diagrams 
      - Catch the risks about the `Colisions`, `Idempotency`, ... 
      - Defining the test cases and write the `Unit` and `Integration` tests
      - Write the docs and `README.md` file 
    ```
  - What implemented with AI help
    ```
      - Initiate and setup the rails app
      - Discuss with the AI about reaching to better descsions together
      - code review, to ensure the code quality
    ```
