<?php
declare(strict_types=1);
/**
 * Copyright 2019 Luis Alberto Pabón Flores
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

namespace App\Generator\Assert;

use Symfony\Component\Validator\Constraint;

/**
 * Validation constraint for postgresql types.
 *
 * @package App\Generator\Assert
 * @author  Luis A. Pabon Flores
 *
 * @Annotation
 */
class PostgresType extends Constraint
{
    /**
     * @var string
     */
    public $message = 'This value is not a supported Postgres version';
}
