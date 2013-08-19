use strict;
use warnings;
use Test::More 0.89;
use Test::TCP;

use NanoMsg::Raw;

my $socket_address = 'inproc://test';

my $surveyor = nn_socket(AF_SP, NN_SURVEYOR);
ok defined $surveyor;
ok nn_setsockopt($surveyor, NN_SURVEYOR, NN_SURVEYOR_DEADLINE, 500);
ok defined nn_bind($surveyor, $socket_address);

my @respondent = map {
    my $s = nn_socket(AF_SP, NN_RESPONDENT);
    ok defined $s;
    ok defined nn_connect($s, $socket_address);
    $s;
} 1 .. 3;

is nn_send($surveyor, 'ABC', 0), 3;

is nn_recv($respondent[0], my $buf, 3, 0), 3;
is nn_send($respondent[0], 'DEF', 0), 3;

is nn_recv($respondent[1], $buf, 3, 0), 3;
is nn_send($respondent[1], 'DEF', 0), 3;

is nn_recv($surveyor, $buf, 3, 0), 3;
is nn_recv($surveyor, $buf, 3, 0), 3;

my $ret = nn_recv($surveyor, $buf, 3, 0);
ok $! == EFSM;
is $ret, undef;

is nn_recv($respondent[2], $buf, 3, 0), 3;
is nn_send($respondent[2], 'GHI', 0), 3;

is nn_send($surveyor, 'ABC', 0), 3;
$ret = nn_recv($surveyor, $buf, 3, 0);
ok $! == EFSM;
is $ret, undef;

ok nn_close $_ for $surveyor, @respondent;

done_testing;
