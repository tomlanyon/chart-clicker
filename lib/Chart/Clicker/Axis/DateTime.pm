package Chart::Clicker::Axis::DateTime;
use Moose;

use Chart::Clicker::Data::Marker;

use DateTime;
use DateTime::Set;
use Graphics::Color::RGB;

extends 'Chart::Clicker::Axis';

has 'format' => (
    is => 'rw',
    isa => 'Str'
);

has 'time_zone' => (
    is => 'rw',
    isa => 'Str'
);

override 'prepare' => sub {
     my ($self, $driver) = @_;

    my ($dstart, $dend);
    eval {
        $dstart = $self->range->lower->isa('DateTime')
                    ? $self->range->lower
                    : DateTime->from_epoch(epoch => $self->range->lower);
        $dend = $self->range->upper->isa('DateTime')
                    ? $self->range->upper
                    : DateTime->from_epoch(epoch => $self->range->upper);
    };

    if(!defined($dstart) || !defined($dend)) {
        $dstart = DateTime->now();
        $dend = DateTime->now();
    }

    my $dur = $dend - $dstart;

    unless(defined($self->format) && length($self->format)) {
        if($dur->years) {
            $self->format('%b %Y');
        } elsif($dur->months) {
            $self->format('%d');
        } elsif($dur->weeks) {
            $self->format('%d');
        } elsif($dur->days) {
            $self->format('%m/%d %H:%M');
        } else {
            $self->format('%H:%M');
        }
    }

    super();

    my $clicker = shift();
    if(!defined($clicker)) {
        die('No clicker?')
    }

    # my @markers = @{ $clicker->markers() };

    my $set = DateTime::Span->from_datetimes(
        start => $dstart, end => $dend
    );

    my $linecolor = Graphics::Color::RGB->new({
        red => 0, green => 0, blue => 0, alpha => .35
    });
    my $fillcolor = Graphics::Color::RGB->new({
        red => 0, green => 0, blue => 0, alpha => .10
    });

    # my @dmarkers;
    # my $day = $set->start->truncate(to => 'day');
    # 
    # my $dayval;
    # while($day < $set->end()) {
    #     if($set->contains($day)) {
    #         if(defined($dayval)) {
    #             push(@dmarkers,
    #                 Chart::Clicker::Data::Marker->new({
    #                     key         => $dayval,
    #                     key2        => $day->epoch(),
    #                     color       => $linecolor,
    #                     inside_color=> $fillcolor,
    #                 })
    #             );
    #             $dayval = undef;
    #         } else {
    #             $dayval = $day->epoch();
    #         }
    #     }
    #     $day = $day->add(days => 1);
    # }
    # if($dayval) {
    #     push(@dmarkers,
    #         Chart::Clicker::Data::Marker->new({
    #             key         => $dayval,
    #             key2        => $day->epoch(),
    #             color       => $linecolor,
    #             inside_color=> $fillcolor,
    #         })
    #     );
    # }
    # 
    # push(@dmarkers, @markers);
    # $clicker->markers(\@dmarkers);

    return 1;
};

sub format_value {
    my $self = shift();
    my $value = shift();

    return $self->format_dt($value) if $value->isa('DateTime');

    my %dtargs = (
        'epoch' => $value
    );
    if($self->time_zone()) {
        $dtargs{'time_zone'} = $self->time_zone();
    }
    my $dt = DateTime->from_epoch(%dtargs);

    return $self->format_dt($dt);
}

sub format_dt {
    my ($self, $dt) = @_;
    return $dt->strftime($self->format());
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
__END__

=head1 NAME

Chart::Clicker::Axis::DateTime - An X or Y Axis using DateTime

=head1 DESCRIPTION

A temporal Axis.  Requires L<DateTime> and L<DateTime::Set>.  Inherits from
Axis, so check the methods there as well.  Expects that times will be in
unix format.

=head1 SYNOPSIS

  my $axis = Chart::Clicker::Axis::DateTime->new;

=head1 ATTRIBUTES

=head2 time_zone

Set/Get the time zone to use when creating DateTime objects!  Accepts an
object or a string ('America/Chicago').

=head2 format

Set/Get the formatting string used to format the DateTime.  See DateTime's
strftime.

=head1 METHODS

=head2 new

Creates a new DateTime Axis.

=head2 format_value

Formats the value using L<DateTime>'s strftime.

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 SEE ALSO

perl(1)

=head1 LICENSE

You can redistribute and/or modify this code under the same terms as Perl
itself.
