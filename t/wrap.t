#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

exit main( @ARGV );

sub main {
    use_ok 'Finance::Libdogecoin';

    test_basic_key_pair_exported();

    done_testing;
    return 0;
}

sub test_basic_key_pair_exported {
    package InternalTest {
        use Test::More;
        use Finance::Libdogecoin qw( generate_key_pair verify_key_pair verify_p2pkh_address );

        my ($priv_key, $pub_key) = generate_key_pair();
        isnt $priv_key, undef, 'generate_key_pair() should return private key';
        isnt $pub_key, undef, '... and public key';

        ok verify_key_pair( $priv_key, $pub_key ),
            'verify_key_pair() should verify that pair';

        ok verify_p2pkh_address( $pub_key ),
            '... and public key should be a valid P2PKH address';

        (my $mangled_priv_key = $priv_key) =~ s/.$/Z/;
        (my $mangled_pub_key  = $pub_key)  =~ s/.$/Z/;
        ok ! verify_key_pair( $mangled_priv_key, $mangled_pub_key ),
            '... and should not verify mangled pairs';
    }
}
