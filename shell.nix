with import <nixpkgs>
{
  config.allowUnfree = true;
};

stdenv.mkDerivation {
  name = "ruby";
  buildInputs = [
    ruby
  ];
  shellHook = ''
    '';
}
