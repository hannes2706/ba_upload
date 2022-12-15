require "ba_upload/version"
require "openssl"

module BaUpload
  def self.export_certificate(file_path:, passphrase:)
    cert = OpenSSL::PKCS12.new(open(file_path).read, passphrase)
    {
      key: Tempfile.new(['key','.pem']).tap{|f| f.write(cert.key.to_s); f.flush},
      cert: Tempfile.new(['cert','.pem']).tap{|f| f.write(cert.certificate.to_s); f.flush},
      ca_cert: Tempfile.new(['ca_cert','.pem']).tap{|f| f.write(cert.ca_certs.reverse.join("\n")); f.flush }
    }
  end

  def self.open_connection(file_path:, passphrase:)
    cert = BaUpload.export_certificate(file_path: file_path, passphrase: passphrase)
    BaUpload::Connection.new(cert[:key], cert[:cert], cert[:ca_cert])
  end
end

require 'ba_upload/connection'
