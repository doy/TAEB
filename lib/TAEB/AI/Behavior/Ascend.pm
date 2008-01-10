#!/usr/bin/env perl
package TAEB::AI::Behavior::Ascend;
use Moose;
extends 'TAEB::AI::Behavior';

sub prepare {
    my $self = shift;

    # are we on <? if so, head up
    if (TAEB->current_tile->floor_glyph eq '<') {
        $self->currently("Ascending");
        $self->next('<');
        #special case to really leave the dungeon
        if (TAEB->z == 1) {
            $self->next('<y     ');
        }
        return 100;
    }

    # find our <
    my $path = TAEB::World::Path->first_match(
        sub { shift->floor_glyph eq '<' },
    );

    $self->currently("Heading towards the upstairs");
    $self->path($path);
    return $path ? 50 : 0;
}

sub urgencies {
    return {
        100 => "ascending stairs",
         50 => "path to upstairs",
    };
}

1;

