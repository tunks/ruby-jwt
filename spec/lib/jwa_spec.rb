require 'spec_helper'
require_relative '../../lib/jwa'

describe JWA do
  context 'HMAC signing, verifying' do
    let(:input) { 'my super awesome input' }
    let(:secret) { 'donottellanyone' }

    [256, 384, 512].each do |bit|
      before(:each) do
        @jwa = JWA.create "HS#{bit}"
        @sig = @jwa.sign input, secret
      end

      it "#{bit} should verify" do
        expect(@jwa.verify(input, @sig, secret)).to eq(true)
      end

      it "#{bit} should not verify" do
        expect(@jwa.verify('different', @sig, secret)).to eq(false)
        expect(@jwa.verify(input, 'different', secret)).to eq(false)
        expect(@jwa.verify(input, @sig, 'let me in')).to eq(false)
      end

      it "#{bit} missing secret" do
        expect{ @jwa.sign(input) }.to raise_error
      end

      it "#{bit} weird input" do
        inpt = { a: [1, 2, 3, 4] }
        data = @jwa.sign(inpt, secret)
        expect(@jwa.verify(inpt, data, secret)).to eq(true)
        expect(@jwa.verify(inpt, data, 'let me in')).to eq(false)
      end
    end
  end

  context 'RSASSA signing, veryfying' do
    let(:input) { 'my super awesome input' }
    let(:public_key) do 
      OpenSSL::PKey::RSA.new File.read(File.join(CERT_PATH, 'jwa', 'rsa-public.pem'))
    end

    let(:private_key) do 
      OpenSSL::PKey::RSA.new File.read(File.join(CERT_PATH, 'jwa', 'rsa-private.pem'))
    end

    let(:wrong_public_key) do
      OpenSSL::PKey::RSA.new File.read(File.join(CERT_PATH, 'jwa', 'rsa-wrong-public.pem')) 
    end

    [256, 384, 512].each do |bit|
      before(:each) do
        @jwa = JWA.create "RS#{bit}"
        @sig = @jwa.sign input, private_key
      end

      it "#{bit} should verify" do
        expect(@jwa.verify(input, @sig, public_key)).to eq(true)
      end

      it "#{bit} should not verify" do
        expect(@jwa.verify(input, @sig, wrong_public_key)).to eq(false)
      end

      it "#{bit} missing sign key" do
        expect{@jwa.sign(input)}.to raise_error
      end

      it "#{bit} missing verify key" do
        expect{@jwa.verify(input, @sig)}.to raise_error
      end

      it "#{bit} weird input" do
        inpt = { a: [1, 2, 3, 4] }
        data = @jwa.sign(inpt, private_key)
        expect(@jwa.verify(inpt, data, public_key)).to eq(true)
        expect(@jwa.verify(inpt, data, wrong_public_key)).to eq(false)
      end
    end
  end

  [256, 384, 512].each do |bit|
    context "RS#{bit} openssl sign -> ruby verify" do
      it 'should verify'
      it 'should not verify'
    end
  end

  [256, 384, 512].each do |bit|
    context "RS#{bit} ruby sign -> openssl verify" do
      it 'should verify'
      it 'should not verify'
    end
  end

  context 'ECDSA signing, verifying' do
    [256, 384, 512].each do |bit|
      it "#{bit} should verify"
      it "#{bit} should not verify"
      it "#{bit} missing sign key"
      it "#{bit} missing verify key"
      it "#{bit} weird input"
    end
  end

  [256, 384, 512].each do |bit|
    context "ES#{bit} openssl sign -> ruby verify" do
      it 'should verify'
      it 'should not verify'
    end
  end

  [256, 384, 512].each do |bit|
    context "ES#{bit} ruby sign -> openssl verify" do
      it 'should verify'
      it 'should not verify'
    end
  end

  context 'NONE' do
    it 'should verify'
    it 'should not verify'
  end

  context 'unsupported algorithm' do
    it 'should throw' do
      expect{ JWA.create('invalid') }.to raise_error
      expect{ JWA.create('HS255') }.to raise_error
    end
  end
end
