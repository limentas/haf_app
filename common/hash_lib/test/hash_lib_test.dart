import 'package:flutter_test/flutter_test.dart';

import 'package:hash_lib/hash_lib.dart';

void main() {
  test('Hash test', () {
    expect(Hash.calc("12345"), "fU4+7IACZxljntTbpokW65THpJoFPgXI+VeP5OWj1+o=");
    expect(
        Hash.calc(
            "7d4e3eec80026719639ed4dba68916eb94c7a49a053e05c8f9578fe4e5a3d7ea"),
        "hWP6C+l30Bk4IXzFm+BgNbW+sfgigmvIXpsA4wJqlrc=");
    expect(Hash.calc("ZXjptij546ohrpgfeokd;cvmq\"WOAIDF{pw9iur3t[r-0woqdascx"),
        "XYzBsPsAWgV25EN2jcl0Q4ApbdZPPyJUOeRYpPTP94Q=");
  });
}
