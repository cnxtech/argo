# frozen_string_literal: true

# Configure dor-services-client to use the dor-services URL
Dor::Services::Client.configure(url: Settings.DOR_SERVICES.URL,
                                username: Settings.DOR_SERVICES.USER,
                                password: Settings.DOR_SERVICES.PASS,
                                token: Settings.DOR_SERVICES.TOKEN,
                                token_header: Settings.DOR_SERVICES.TOKEN_HEADER)
