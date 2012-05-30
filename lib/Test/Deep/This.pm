#!/usr/bin/perl
package Test::Deep::This;
use strict;
use base qw(Exporter);
our @EXPORT = (qw/this/);

use Test::Deep;

sub this() {
    bless { code => sub { $_[0] }, msg => "." };
}

sub apply {
    ref $_[0] eq 'Test::Deep::This' ? $_[0]->{code}($_[1]) : $_[0];
}

sub upgrade {
    my $self = shift;
    return $self if ref $self eq 'Test::Deep::This';
    return bless {
        code => sub { return $self },
        msg => "\"$self\"", #FIXME: quote
    }
}

sub operator {
    my ($op) = @_;
    return eval "sub { \$_[0] $op \$_[1] }";
}

use overload '""' => sub { $_[0]->{msg} };

use overload
    map {
        my $op = $_;
        my $operator = operator($op);
  
        $op => sub {
            my ($left, $right, $reorder) = @_;
            ($left, $right) = ($right, $left) if $reorder;
            $left = upgrade($left);
            $right = upgrade($right);
            return code(sub {
                my $val = shift;
                my $ret = $operator->($left->{code}->($val), $right->{code}->($val));
                return $ret, "("."$left".") $op ("."$right".")";
            });
        }
    } qw/> < >= <= == != lt gt le ge eq ne/;

use overload
    map {
        my $op = $_;
        my $operator = operator($op);
  
        $op => sub {
            my ($left, $right, $reorder) = @_;
            ($left, $right) = ($right, $left) if $reorder;
            $left = upgrade($left);
            $right = upgrade($right);
            return bless {
                code => sub {
                    my $val = shift;
                    $operator->($left->{code}->($val), $right->{code}->($val));
                }, 
                msg => "("."$left".") $op ("."$right".")",
            };
        }
    } qw(+ - * / % ** << >> x .);

use overload 'fallback' => 0;

1;
