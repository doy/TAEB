#!/usr/bin/env perl
package TAEB::OO;
use Moose;
use MooseX::AttributeHelpers;

use Sub::Exporter;
use Sub::Name;

use TAEB::Object;
use TAEB::Meta::Class;
use TAEB::Meta::Trait::Provided;
use TAEB::Meta::Trait::Persistent;
use TAEB::Meta::Types;
use TAEB::Meta::Overload;

{
    my $CALLER;

    my %exports = (
        install_spoilers => sub {
            return subname 'TAEB::OO::install_spoilers' => sub {
                for my $field (@_) {
                    $CALLER->meta->add_method($field => sub {
                        shift->lookup_spoiler($field);
                    });
                }
            };
        },
    );

    my $exporter = Sub::Exporter::build_exporter({
        exports => \%exports,
    });

    sub import {
        $CALLER = caller;

        strict->import;
        warnings->import;

        return if $CALLER eq 'main';

        Moose::init_meta($CALLER, 'TAEB::Object', 'TAEB::Meta::Class');
        Moose->import({into => $CALLER});

        goto $exporter;
    };
}

no Moose;

1;

