import datetime
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID

domain = "poc-apps-ci36u7.internal"

# Generate 2048-bit RSA private key
key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

subject = issuer = x509.Name([
    x509.NameAttribute(NameOID.COMMON_NAME, domain),
    x509.NameAttribute(NameOID.ORGANIZATION_NAME, "POC Organization"),
])

# Set valid starting 1 day ago to avoid clock skew rejection by AWS ACM
now = datetime.datetime.now(datetime.timezone.utc)
not_before = now - datetime.timedelta(days=1)
not_after = now + datetime.timedelta(days=365)

cert = (
    x509.CertificateBuilder()
    .subject_name(subject)
    .issuer_name(issuer)
    .public_key(key.public_key())
    .serial_number(x509.random_serial_number())
    .not_valid_before(not_before)
    .not_valid_after(not_after)
    .add_extension(
        x509.SubjectAlternativeName([
            x509.DNSName(domain),
            x509.DNSName(f"*.{domain}"),
            x509.DNSName("localhost"),
        ]),
        critical=False,
    )
    .add_extension(
        x509.BasicConstraints(ca=False, path_length=None),
        critical=True,
    )
    .add_extension(
        x509.KeyUsage(
            digital_signature=True,
            content_commitment=False,
            key_encipherment=True,
            data_encipherment=False,
            key_agreement=False,
            key_cert_sign=False,
            crl_sign=False,
            encipher_only=False,
            decipher_only=False,
        ),
        critical=True,
    )
    .sign(key, hashes.SHA256())
)

with open("cert_key.pem", "wb") as f:
    f.write(key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    ))

with open("cert.pem", "wb") as f:
    f.write(cert.public_bytes(serialization.Encoding.PEM))

print(f"Generated cert for {domain}, valid from {not_before} to {not_after}")
