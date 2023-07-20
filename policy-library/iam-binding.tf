
resource "google_project_iam_binding" "test_iam_binding" {
  project = "xtf-validator"
  role    = "roles/viewer"
  members = [
    "user:ixxbit@gmail.com",
  ]
}


/* 
resource "google_project_iam_binding" "test_iam_binding" {
  project = "xtf-validator"
  role    = "roles/viewer"
  members = [
    "serviceAccount:policy-validation@xtf-validator.iam.gserviceaccount.com", "user:ixxbit@gmail.com"
  ]
} 
*/