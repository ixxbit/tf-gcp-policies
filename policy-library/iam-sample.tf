terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.84"
    }
  }
}
resource "google_project_iam_binding" "test_iam_binding" {
  project = "xtf-validator"
  role    = "roles/viewer"
  members = [
    "serviceAccount:policy-validation@xtf-validator.iam.gserviceaccount.com", "user:ixxbit@gmail.com"
  ]
}