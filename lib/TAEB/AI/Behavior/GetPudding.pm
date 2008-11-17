#!/usr/bin/env perl
package TAEB::AI::Behavior::GetPudding;
use TAEB::OO;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    return URG_NONE unless TAEB->can_kick;
    return URG_NONE unless TAEB->current_level->has_type('sink');

    my ($sink, $dir);
    my $useful_sink = sub {
        my ($tile, $d) = @_;
        return ($sink, $dir) = ($tile, $d)
            if $tile->type eq 'sink'
            && $tile->is_empty
            && !$tile->got_pudding
            && $tile->kicked < 50; # don't want to kick an emptied bones sink forever

        return 0;
    };

    if (TAEB->any_adjacent($useful_sink)) {
        $self->do(kick => direction => $dir);
        $self->currently("Kicking a sink for a pudding");
        return URG_UNIMPORTANT;
    }

    my $path = TAEB::World::Path->first_match($useful_sink, why => "GetPudding");
    $self->if_path($path => "Heading towards a sink");
}

sub urgencies {
    return {
        URG_UNIMPORTANT, "kicking an adjacent sink",
        URG_FALLBACK,    "path to a sink",
    },
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

