CREATE EXTERNAL SCHEMA s3_spectrum_random_profile FROM DATA CATALOG
DATABASE 'random_profile'
IAM_ROLE 'arn:aws:iam::xxxxxxxxx:role/redshift_dedicated_role';