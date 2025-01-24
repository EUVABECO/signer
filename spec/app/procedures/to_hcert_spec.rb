# module Procedures
#   class DummyTime
#     def now
#       1736785067
#     end
#   end
#   RSpec.describe ToHcert do
#     let(:time) { DummyTime.new }
#     let(:dependencies) { Initializers.init_all(time:) }

#     before do
#       dependencies[:priv_key_store].add(
#         JWT::JWK.new(
#           {
#             kty: 'EC',
#             crv: 'P-256',
#             alg: 'ES256', # required for JWT.encode
#             x: 'FDMpzOeGjkFpJ1mc9lo0884v/aVafspp7YkZo5TULw8',
#             y: 'YPfxp4DYp4O/t6LdayeW6BKNu87509Fo25Uplxo257k',
#             d: 'bBOCdlrsU1jxF3M9KBwce9w5iE0EpFoebGfIWLwgbBk',
#             kid: 'AsymmetricECDSA256'
#           }
#         )
#       )
#       dependencies[:pub_key_store].add(
#         JWT::JWK.new(
#           {
#             kty: 'EC',
#             crv: 'P-256',
#             alg: 'ES256', # required for JWT.encode
#             x: 'FDMpzOeGjkFpJ1mc9lo0884v/aVafspp7YkZo5TULw8',
#             y: 'YPfxp4DYp4O/t6LdayeW6BKNu87509Fo25Uplxo257k',
#             d: 'bBOCdlrsU1jxF3M9KBwce9w5iE0EpFoebGfIWLwgbBk',
#             kid: 'AsymmetricECDSA256'
#           }
#         )
#       )
#     end
    
#     subject { dependencies[:procedures][:to_hcert] }

#     it "generates the same CWT as the python implementation (base45 and compressed)" do
#       hcert = "6BFOXN*TS0BI$ZD*O9WPC1$C6/D4C9A:CZVLQP9NUKIIL$V8+KA2.S869-%2ONLT$VAVDGOT0-6PV5YIJ7S47*KB*KYQTHFT.T4RZ4F%5B/9BL5UMUQ$9IN9P8QVF9-.PN3Q%.P9/9-3AKI6+T6LEQ736/PKYMM7/AT4VO6HK+AYUJ9CT:5C6ZV3ETC*CGM8 SN::M5+5W5W9QU$QPN/G30O7+4./TN28NBLG9MP:P9PT+BO24WC*2Z:A*:H9QB23ES LJAQIB5V50ZC89-8".b
#       expected_parsed_cwt = dependencies[:procedures][:from_hcert].call(hcert:)
#       hcert_data = {
#         ver: "1.0.0",
#         nam: {
#           fnt: "JEAN",
#           gnt: "Michel"
#         },
#         dob: "1978-01-01",
#         v: []
#       }
#       result = dependencies[:procedures][:from_hcert].call(hcert: subject.call(hcert_data:))
#       expect(result.except(:signature, :payload)).to eq(expected_parsed_cwt.except(:signature, :payload))
#     end
#   end
# end