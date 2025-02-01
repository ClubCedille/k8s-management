# We create a service account so vault can access the KMS service
resource "google_service_account" "vault_kms_service_account" {
  account_id   = "${var.name_prefix}-vault-gcpkms"
  display_name = "Vault KMS for auto-unseal"
}

resource "google_service_account_key" "vault_kms_service_account_key" {
  service_account_id = google_service_account.vault_kms_service_account.name
}

# Create a KMS key ring, logical space to contain keys
resource "google_kms_key_ring" "key_ring" {
  name     = "${var.name_prefix}-vault-keyring"
  location = "${var.gcloud_region}"
}

# Create a crypto key for the key ring. This key will be used
# to automatically unseal Vault
resource "google_kms_crypto_key" "crypto_key" {
  name            = "${var.name_prefix}-vault-cryptokey"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "100000s"
}

# We give vault service account access to that key ring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.vault_kms_service_account.email}",
  ]
}

resource "kubernetes_secret" "kms_creds" {
  metadata {
    name = "kms-creds"
    namespace = "vault"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.vault_kms_service_account_key.private_key)
  }

  type = "kubernetes.io/generic"
}

resource "kubernetes_secret" "kms_infos" {
  metadata {
    name = "kms-infos"
    namespace = "vault"
  }

  data = {
    "region" = var.gcloud_region
    "project" = var.gcloud_project
    "keyring" = google_kms_key_ring.key_ring.name
    "cryptokey" = google_kms_crypto_key.crypto_key.name
  }

  type = "kubernetes.io/generic"
}