shared_examples_for 'a signed resource' do

  describe 'when the request comes from the physical device' do

    before { access_token.application_id = Defaults.phisical_application_id; access_token.save }

    describe 'with valid signature' do

      before { pp params }
      let(:signature) { Signature.sign(params, resource.secret) }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.put "#{uri}?source=physical", params.to_json }

      it 'gets a 200 response' do
        page.status_code.should == 200
      end
    end

    describe 'with an invalid signature' do

      let(:signature) { Signature.sign(params, 'not-valid-secret') }

      before { page.driver.header 'X-Physical-Signature', signature }
      before { page.driver.put "#{uri}?source=physical", params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end

    describe 'whit no signature' do

      before { page.driver.put "#{uri}?source=physical", params.to_json }

      it 'gets a 401 response' do
        page.status_code.should == 401
      end
    end
  end
end