#!/usr/bin/env perl
package TAEB::World::Item::Potion;
use Moose;
extends 'TAEB::World::Item';
with 'TAEB::World::Item::Role::Lightable';

has '+class' => (
    default => 'potion',
);

has is_diluted => (
);

1;

