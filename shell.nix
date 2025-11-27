with import <nixpkgs> {
  config.allowUnfree = true;
};

stdenv.mkDerivation {
  name = "ruby";
  buildInputs = [
    ruby_3_4
    jekyll
    rubyPackages_3_4.eventmachine
  ];
  shellHook = '''';
}
