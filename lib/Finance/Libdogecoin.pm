package Finance::Libdogecoin;
# ABSTRACT: Use the libdogecoin shared library from Perl!

use Finance::Libdogecoin::FFI;

sub import {
    my ($self, @symbols) = @_;
    my $caller = caller(1);

    for my $symbol (@symbols) {
        next if $symbol =~ /^_/;
        next unless my $ref = 'Finance::Libdogecoin::FFI'->can( $symbol );
        my $wrapper = sub {
            Finance::Libdogecoin::FFI::dogecoin_ecc_start();
            if (wantarray()) {
                my @ret = $ref->(@_);
                Finance::Libdogecoin::FFI::dogecoin_ecc_stop();
                return @ret;
            }
            else {
                my $ret = $ref->(@_);
                Finance::Libdogecoin::FFI::dogecoin_ecc_stop();
                return $ret;
            }
        };
        do { no strict 'refs'; *{$caller . '::' . $symbol} = $wrapper };
    }
}

'such currency';
