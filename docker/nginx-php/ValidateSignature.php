<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\ValidatePostSize as Middleware;

class ValidateSignature extends Middleware
{
    /**
     * The URIs that should be excluded from signature validation.
     *
     * @var array<int, string>
     */
    protected $except = [
        //
    ];
}
