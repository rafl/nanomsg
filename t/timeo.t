use strict;
use warnings;
use Test::More 0.89;
use Time::HiRes 'clock_gettime', 'CLOCK_REALTIME';

use NanoMsg::Raw;

sub timeit (&) {
    my ($cb) = @_;

    my $started = clock_gettime CLOCK_REALTIME;
    my @ret = $cb->();
    my $finished = clock_gettime CLOCK_REALTIME;

    ($finished - $started, @ret);
}

my $s = nn_socket AF_SP, NN_PAIR;
cmp_ok $s, '>=', 0;

my $timeo = 100;
ok nn_setsockopt($s, NN_SOL_SOCKET, NN_RCVTIMEO, $timeo);

my ($elapsed, $ret) = timeit {
    nn_recv($s, my $buf, 3, 0);
};

ok !defined $ret;
ok $! == EAGAIN;
cmp_ok $elapsed, '>=', 0.1;
cmp_ok $elapsed, '<=', 0.1010;

ok nn_setsockopt($s, NN_SOL_SOCKET, NN_SNDTIMEO, $timeo);

($elapsed, $ret) = timeit {
    nn_send($s, 'ABC', 0);
};

ok !defined $ret;
ok $! == EAGAIN;
cmp_ok $elapsed, '>=', 0.1;
cmp_ok $elapsed, '<=', 0.1010;

ok nn_close $s;

done_testing;
