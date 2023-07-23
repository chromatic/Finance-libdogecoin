#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

exit main( @ARGV );

sub main {
    use_ok 'Finance::Libdogecoin::FFI';

    test_basic_key_pair();
    test_generate_key_pair();
    test_verify_key();

    test_generate_hd_key_pair();
    test_generate_derived_hd_key();
    test_generate_derived_hd_key_by_path();

    done_testing;
    return 0;
}

sub test_basic_key_pair {
    Finance::Libdogecoin::FFI::context_start();

    my ($priv_key, $pub_key) = Finance::Libdogecoin::FFI::generate_key_pair();
    isnt $priv_key, undef, 'generate_key_pair() should return private key';
    isnt $pub_key, undef, '... and public key';

    ok Finance::Libdogecoin::FFI::verify_key_pair( $priv_key, $pub_key ),
        'verify_key_pair() should verify that pair';

    ok Finance::Libdogecoin::FFI::verify_p2pkh_address( $pub_key ),
        '... and public key should be a valid P2PKH address';

    (my $mangled_priv_key = $priv_key) =~ s/.$/Z/;
    (my $mangled_pub_key  = $pub_key)  =~ s/.$/Z/;
    ok ! Finance::Libdogecoin::FFI::verify_key_pair( $mangled_priv_key, $mangled_pub_key ),
        '... and should not verify mangled pairs';

    Finance::Libdogecoin::FFI::context_stop();
}

sub test_generate_key_pair {
    Finance::Libdogecoin::FFI::context_start();

    my ($mainnet_priv_key, $mainnet_pub_key) = Finance::Libdogecoin::FFI::generate_key_pair( 0 );
    isnt $mainnet_priv_key, undef, 'generate_key_pair() should return mainnet private key';
    isnt $mainnet_pub_key, undef, '... and mainnet public key';

    ok Finance::Libdogecoin::FFI::verify_key_pair( $mainnet_priv_key, $mainnet_pub_key, 0 ),
        'verify_key_pair() should verify that pair for mainnet';

    ok ! Finance::Libdogecoin::FFI::verify_key_pair( $mainnet_priv_key, $mainnet_pub_key, 1 ),
        '... but not for testnet';

    my ($testnet_priv_key, $testnet_pub_key) = Finance::Libdogecoin::FFI::generate_key_pair( 1 );
    isnt $testnet_priv_key, undef, 'generate_key_pair() should return testnet private key';
    isnt $testnet_pub_key, undef, '... and testnet public key';

    ok Finance::Libdogecoin::FFI::verify_key_pair( $testnet_priv_key, $testnet_pub_key, 1 ),
        'verify_key_pair() should verify that pair for testnet';

    ok ! Finance::Libdogecoin::FFI::verify_key_pair( $testnet_priv_key, $testnet_pub_key, 0 ),
        '... but not for mainnet';

    Finance::Libdogecoin::FFI::context_stop();
}

sub test_verify_key {
    Finance::Libdogecoin::FFI::context_start();

    ok Finance::Libdogecoin::FFI::verify_p2pkh_address( 'DFhv7MMnDBGeaNmKybvfwF3HaJxN3Dtg3y' ),
        'Valid address should validate';
    ok ! Finance::Libdogecoin::FFI::verify_p2pkh_address( 'Fhv7MMnDBGeaNmKybvfwF3HaJxN3Dtg3yD' ),
        'Invalid address should not';

    Finance::Libdogecoin::FFI::context_stop();
}

sub test_generate_hd_key_pair {
    Finance::Libdogecoin::FFI::context_start();

    my ($mainnet_priv_key_master, $mainnet_pub_key_master) = Finance::Libdogecoin::FFI::generate_hd_master_pub_key_pair( 0 );
    isnt $mainnet_priv_key_master, undef, 'generate_hd_master_pub_key_pair() should return mainnet private key master';
    isnt $mainnet_pub_key_master, undef, '... and mainnet public key master';

    ok Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $mainnet_priv_key_master, $mainnet_pub_key_master, 0 ),
        'verify_master_priv_pub_keypair() should verify that pair for mainnet';

    ok ! Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $mainnet_priv_key_master, $mainnet_pub_key_master, 1 ),
        '... but not for testnet';

    my ($testnet_priv_key_master, $testnet_pub_key_master) = Finance::Libdogecoin::FFI::generate_hd_master_pub_key_pair( 1 );
    isnt $testnet_priv_key_master, undef, 'generate_hd_master_pub_key_pair() should return testnet private key';
    isnt $testnet_pub_key_master, undef, '... and testnet public key';

    ok Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $testnet_priv_key_master, $testnet_pub_key_master, 1 ),
        'verify_master_priv_pub_keypair() should verify that pair for testnet';

    ok ! Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $testnet_priv_key_master, $testnet_pub_key_master, 0 ),
        '... but not for mainnet';

    Finance::Libdogecoin::FFI::context_stop();
}

sub test_generate_derived_hd_key {
    Finance::Libdogecoin::FFI::context_start();

    my ($mainnet_priv_key_master, $mainnet_pub_key_master) = Finance::Libdogecoin::FFI::generate_hd_master_pub_key_pair( 0 );

    my $derived_pub_key = Finance::Libdogecoin::FFI::generate_derived_hd_pub_key($mainnet_priv_key_master);

    ok Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $mainnet_priv_key_master, $derived_pub_key, 0 ),
        'verify_master_priv_pub_keypair() should verify that pair for mainnet';

    ok ! Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $mainnet_priv_key_master, $derived_pub_key, 1 ),
        '... but not for testnet';

    my ($testnet_priv_key_master, $testnet_pub_key_master) = Finance::Libdogecoin::FFI::generate_hd_master_pub_key_pair( 1 );

    my $testnet_derived_pub_key = Finance::Libdogecoin::FFI::generate_derived_hd_pub_key($testnet_priv_key_master);

    ok Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $testnet_priv_key_master, $testnet_derived_pub_key, 1 ),
        'verify_master_priv_pub_keypair() should verify that pair for testnet';

    ok ! Finance::Libdogecoin::FFI::verify_master_priv_pub_keypair( $testnet_priv_key_master, $testnet_derived_pub_key, 0 ),
        '... but not for mainnet';

    Finance::Libdogecoin::FFI::context_stop();
}

sub test_generate_derived_hd_key_by_path {
    Finance::Libdogecoin::FFI::context_start();

    # taken from libdogecoin examples; don't use these keys apart from testing
    my $mainnet_priv_key_master = 'dgpv51eADS3spNJh8h13wso3DdDAw3EJRqWvftZyjTNCFEG7gqV6zsZmucmJR6xZfvgfmzUthVC6LNicBeNNDQdLiqjQJjPeZnxG8uW3Q3gCA3e';

    my %public = (
        "m/44'/3'/0'/0/0" =>
            "dgub8vXjuDpn2sTkerBdjSfq9kmjhaQsXHxyBkYrikw84GCYz9ozcdwvYPo5SSDWqZUVT5d4jrG8CHiGsC1M7pdETPhoKiQa92znT2vG9YaytBH",
        "m/44'/3'/1'/0/1" =>
            "dgub8wdiEmcUJMWMxz36J7L7hP5Ge1uZpvHgEJvBkWgQa2wRYbLVyuWq3WWaiK3ZgYs893RqrgZN3QgRghPXkpRr7kdT44XVSaJuwMF1PTHi2mQ",
    );


    while (my ($path, $pubkey) = each %public) {
        my $derived_pub_key = Finance::Libdogecoin::FFI::get_derived_hd_key_by_path(
            $mainnet_priv_key_master,
            $path,
            0
        );
        is $derived_pub_key, $pubkey,
            'derived pub key by path should match example';
    }

    my %private = (
        "m/44'/3'/0'/0/0" =>
            "dgpv5BeiZXttUioRMzXUhD3s2uE9F23EhAwFu9meZeY9G99YS6hJCsQ9u6PRsAG3qfVwB1T7aQTVGLsmpxMiczV1dRDgzpbUxR7utpTRmN41iV7",
        "m/44'/3'/1'/0/1" =>
            "dgpv5Ckgu5gakCr2g8NwFsi9aXXgBTXvzoFxwi8ybQHRmutQzYDoa8y4QD6w94EEYFtinVGD3ZzZG89t8pedriw9L8VgPYKeQsUHoZQaKcSEqwr"
    );

    while (my ($path, $pubkey) = each %private) {
        my $derived_priv_key = Finance::Libdogecoin::FFI::get_derived_hd_key_by_path(
            $mainnet_priv_key_master,
            $path,
            1
        );
        is $derived_priv_key, $pubkey,
            'derived priv key by path should match example';
    }

    Finance::Libdogecoin::FFI::context_stop();
}
