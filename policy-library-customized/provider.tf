provider "google" {
  credentials = file("../../xtf-validator-d0dced055346.json")
  project     = "xtf-validator"
  region      = "us-central1"
  zone        = "us-central1-c"
}
