# Diaspora App Manifest Generator


class ManifestGenerator
  require "rubygems"
  require "openssl"
  require "jwt"
  require "yaml"
  require "pp"

  def generate_keys
    priv_key = OpenSSL::PKey::RSA.generate(2048)
    Dir.mkdir(File.join(Dir.pwd, "keys"))

    priv_path = File.join(Dir.pwd, "keys", "private.pem")
    pub_path = File.join(Dir.pwd, "keys", "public.pem")

    @private_key = priv_key
    @public_key = priv_key.public_key

    puts "writing private key to: " + priv_path
    priv_f = File.new(priv_path, "w")
    priv_f.write(@private_key.export)
    priv_f.close

    puts "writing public key to: " + pub_path
    pub_f = File.new(pub_path, "w")
    pub_f.write(@public_key.export)
    pub_f.close
  end

  def write_manifest
    self.generate_keys

    manifest_path = File.join(Dir.pwd, "manifest.json")
    puts "writing manifest to: " + manifest_path

    man_f = File.new(manifest_path, "w")
    man_f.write(self.package_manifest)
    man_f.close
  end

  def package_manifest
    JSON.generate({:public_key => @public_key,
                   :jwt => JWT.encode(self.generate_manifest, @private_key, "RS512")})
  end

  def load_yaml
    configs = YAML::load(File.open("config.yml"))

    @manifest_fields = Hash.new
    configs["manifest_fields"].each do |k,v|
      @manifest_fields[k] = v
    end

    @permissions = Hash.new
    configs["permissions"].each do |type,permissions|
      permissions.each do |access,description|
        @permissions[type] = {:type => type,
                              :access => access,
                              :description => description}
      end
    end

    @application_base_url = configs["application_base_url"]
  end

  def generate_manifest
    self.load_yaml
    @manifest_fields.merge(:permissions => @permissions,
                           :application_base_url => @application_base_url)
  end
end

generator = ManifestGenerator.new
generator.write_manifest
