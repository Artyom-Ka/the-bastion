package OVH::Result;

# vim: set filetype=perl ts=4 sw=4 sts=4 et:
use common::sense;

# not enabled on prod, see "trace" comment below
# use Carp ();
# $Carp::MaxArgLen  = 512;
# $Carp::MaxArgNums = 32;

use parent qw(Exporter);
our @EXPORT = qw{ R };    ## no critic (AutomaticExportation)

use overload (
    'bool' => \&is_ok,
    '""'   => \&msg,
);

sub new {                 ## no critic (ArgUnpacking)
    my $type   = shift;
    my %params = @_;
    my $err    = $params{'err'};
    my $value  = $params{'value'};
    my $msg    = $params{'msg'};
    my $silent = $params{'silent'};

    my $Object = {
        err   => $err,
        value => $value,
        msg   => $msg,

        # uncomment this and 'use Carp' above to trace results,
        # slows down code and gets noticeable on very busy bastions
        #       trace => Carp::longmess("new Result"),
    };

    bless $Object, 'OVH::Result';

    # uncomment this and 'use Carp' above to print on STDERR any non-OK result
    # that is generated by any function, helpful to debug complex new features
    # print STDERR Carp::longmess("$0 R[" . ($err ? $err : '<u>') . " " . ($value ? $value : '<u>') . " " . ($msg ? $msg : '<u>')) if (!$silent && !$Object->is_ok());

    return $Object;
}

sub R { return OVH::Result->new(err => shift, @_); }    ## no critic (ArgUnpacking)

=cut uncomment for result tracing
sub R {
    my ($package, $filename, $line) = caller(0);
    my (undef,undef,undef,$sub)     = caller(1);
    my $err = shift;
    my %params = @_;
    print "R[err=$err msg=".$params{'msg'}."] sub=$sub in $filename:$line\n";
    return OVH::Result->new(err => $err, %params);
}
=cut

sub err   { return shift->{'err'} }
sub value { return shift->{'value'} }
sub msg   { return $_[0]->{'msg'} ? $_[0]->{'msg'} : $_[0]->{'err'} }    ## no critic (ArgUnpacking)

sub is_err { return shift->{'err'} =~ /^ERR/ }
sub is_ok  { return shift->{'err'} =~ /^OK/ }
sub is_ko  { return shift->{'err'} =~ /^KO/ }

sub TO_JSON {
    my $self = shift;
    return {
        error_code    => $self->err,
        value         => $self->value,
        error_message => $self->msg,
    } if (ref $self eq 'OVH::Result');
    return {};
}

1;