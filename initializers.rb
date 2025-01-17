require 'logger'
require 'json'
require 'jwt'
require "zlib"
require 'base45'
require 'base64'
require 'bundler'
require "rqrcode"
require "securerandom"
require 'nuva'

Bundler.require(:default)

$stdout.sync = true

$loader = Zeitwerk::Loader.new
$loader.push_dir('app')
$loader.setup

module Initializers
  def self.init_all(**dependencies)
    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG
    dependencies[:time] ||= Time

    dependencies[:logger] ||= logger

    pub_key_store = Utils::KeyStore.new(pub: true)
    dependencies[:pub_key_store] ||= pub_key_store
    priv_key_store = Utils::KeyStore.new(pub: false)
    dependencies[:priv_key_store] ||= priv_key_store

    signer = Cose::Signer.new(priv_key_store:, pub_key_store:)
    dependencies[:signer] ||= signer

    router = Web::Router.new(Hash.new(->(_) { [404, {}, []] }))

    dependencies[:nuva] ||= Nuva::Nuva.load
    dependencies[:md2pdf] ||= Utils::Md2Pdf.new
    procedures = init_procedures(priv_key_store:, signer:, router:, nuva: dependencies[:nuva], md2pdf: dependencies[:md2pdf], time: dependencies[:time])
    web_router = init_router(procedures:, router:)
    dependencies[:procedures] ||= procedures
    dependencies[:web_router] ||= web_router
    dependencies[:app] ||= Web::App.new(web_router:)
    dependencies[:jwks_server] ||= Web::JwksServer.new(pub_key_store:, logger:)
    dependencies
  end

  def self.init_procedures(priv_key_store:, signer:, router:, md2pdf:, nuva:, time:)
    to_cwt = Procedures::ToCwt.new(priv_key_store:, signer:, time:)
    to_hcert = Procedures::ToHcert.new(signer:, to_cwt:)
    to_jwt = Procedures::ToJwt.new(priv_key_store:)
    {
      to_base45: Procedures::ToBase45.new,
      to_cwt:,
      to_jwt:,
      to_zip: Procedures::ToZip.new,
      to_hcert:,
      to_hcert_qr_code: Procedures::ToHcertQrCode.new(to_hcert:),
      from_hcert: Procedures::FromHcert.new(signer:),
      to_jwt_qr_code: Procedures::ToJwtQrCode.new(to_jwt:),
      pipeline: Procedures::Pipeline.new(router:),
      to_hcert_pdf: Procedures::ToHcertPdf.new(to_hcert:, md2pdf:, nuva:)
    }
  end

  def self.init_router(router:, procedures:)
    router.route(method: 'to_base_45', to: procedures[:to_base45])
    router.route(method: 'to_cwt', to: procedures[:to_cwt])
    router.route(method: 'to_jwt', to: procedures[:to_jwt])
    router.route(method: 'to_zip', to: procedures[:to_zip])
    router.route(method: 'to_hcert', to: procedures[:to_hcert])
    router.route(method: 'to_hcert_qr_code', to: procedures[:to_hcert_qr_code])
    router.route(method: 'to_jwt_qr_code', to: procedures[:to_jwt_qr_code])
    router.route(method: 'to_hcert_pdf', to: procedures[:to_hcert_pdf])

    router.route(method: 'pipeline', to: procedures[:pipeline])

    router.route(method: 'from_hcert', to: procedures[:from_hcert])
  end
end
