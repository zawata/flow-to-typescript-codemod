# Getting Started

  If you had a custom settings.json you will need to rectify it with the new settings.json file in the repo which configured vscode to use the same version of typescript that we do. not including these options may cause vscode to report errors where the compiler doesn't and vice-versa

  checkout the latest development branch  
  `git switch -C development origin/development`

  you will need to clean and bootstrap  
  `yarn clean && yarn bootstrap`

  I recommend now restarting VSCode as it seemed to experience some issues converting from Flow to typescript.



# Development Changes:
## Large Changes:
  - redux-saga
    - definitions are customized to match the flow definitions we were using
    - Saga<> has been replaced with SagaGenerator<>
      - Saga typically indicates a function that returns a Generator, I've created SagaGenerator to clarify this distinction
    - LifecycleSaga<> now takes a generic param to indicate it's saga's return value. if not present it default to any
  - reselect
    - definitions are completely custom and incompatible with upstream definitions :/
    - variadic selector definitions are a little wonky but are discouraged anyways.
      - prefer using `any` for the props type on parametric or parametric-adjacent selectors as is better for the resulting function declaration. otherwise use `void`
  - react
    - Numerous React Types have been renamed. most starting with `React` such as `Element` becoming `ReactElement`
    - `props: Props` should not be declared in Class-Components. this is not valid
    - StatelessFunctionalComponent does not exist. it is now FC or FunctionComponent
  - `global` has been replaced with `globalThis`. accessing non-standard properties on global will fail
    - this does not apply to `window` which is typed as `Window & GlobalThis`
    - new global Props (or existing one's I haven't added yet) can be added to the `./src/types/global.d.ts`
  - Node/React/Browser Definitions are no-longer stuck in 2019 as they were with flow.

## Environment Changes
   - a separate flow-extension is no longer required, TS support is built into vscode
   - `yarn flow` and `yarn flow:*` are now deprecated, use `yarn tsc` instead.
   - The project now includes prettier as an auto-formatter. This can be run with `yarn prettier:fix` to auto-format the codebase, or `yarn prettier` to check if it's been modified

## Writing typed-code
### Const assertions

when writing an object such as
```ts
const obj = {
  a: 'a',
  b: 'b',
  c: 'c'
}
```

you may find that without explicitly typing it(which is cumbersome) that the object is implicitly typed as `{ a: string, b: string, c: string }`. This is because typescript assumes that the properties of the object can be changed to other values

Typescript (and actually later versions of flow we never used) support a feature called [const assertions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions) which can be used to declare that an object will not be mutated and increase the specificity of the resulting type. in the above example the inferred type would then be `{ readonly a: 'a', readonly b: 'b', readonly c: 'c' }`

### Enums

In flowJs we would normally write enums as
```js
const letterValues = Object.freeze({
  A: 'a',
  B: 'b',
  C: 'c',
});

export type LetterValues = $Values<typeof letterValues>;
```

In typescript this is converted to a new syntax while the meaning and usage remains the same.
```ts
enum LetterValues {
  A = 'a',
  B = 'b',
  C = 'c',
}

type LetterValues = (typeof LetterValues)[keyof typeof LetterValues];
```

but we can declare enums as actual enums now!
```ts
enum LetterValues {
  A = 'a',
  B = 'b',
  C = 'c',
}
```

and these can be spread to const blocks if the values need to be exported individually:

```ts
export const {
  A,
  B,
  C
} = LetterValues;
```

#### ⚠️ Note that typescript has the ability to declare `const enum` which are functionally the same(as far as I know) other than they cannot exported from the file they were declared in.

<br />

### Casts

casts are done with the `<var> as <Type>` syntax. flow-style type-casts(`(<var>: <type>)`) are not valid.

#### ⚠️ Beware of operator precedence when using the new cast syntax `(yield select(...)) as <Type>` is required as the `as` operator has a higher precedence than the `yield` operator)

To force a cast between 2 types, typescript recommends casting through unknown rather than any, as it is more explicit.
```ts
const a = (b as unknown) as A;
```


### Types and Interfaces

  Typescript does not have a concept of "inexact" objects. All objects are exact. The `{|...|}` syntax is not valid.

  Typescript has 2 different methods for declaring object types. they can mostly be used interchangeably but eslint and prettier will assert you which one you need to normally use. 

  types are declared with the `type` keyword and use a syntax similar to objects: 
  ```ts
  type User = {
    name: string;
    age: number;
  }
  ```

  interfaces are declared with the `interface` keyword and use a syntax similar to classes: 
  ```ts
  interface IUser {
    name: string;
    age: number;
  }
  ```

  Interfaces are extendable while types are not.
  ```ts
  interface IUser {
    name: string;
    age: number;
  }

  interface IUserWithEmail extends IUser {
    email: string;
  }
  ```

<br />

### Generics
  typescript Generics are far far better than Flow's and don't interfere with eslint. prefer adding generics to functions over using `any`

  Generics are declared with `<T>`. `<T>(t: T) => T` would be a function that can take any type and return that same type.

  the `extends` keyword is used to constrain the Type a Generic can be. `<T extends Array<any>>(t: T) => T` would be a function that can only contain arrays.

  `extends` can also be used as a kind-of conditional to verify if a type can be constrained to a given bound.
  ```
    type isArray<T> = T extends Array<any>
      ? true
      : false;
  ```

  This is helpful in cases where we want add multiple call definitions to a function.

```ts
  type F<T extends boolean> = T extends true
    ? (t: true, param: number) => T=void // if T === true
    : T extends false
      ? (t: false, param: string) => T; // if T === false
      : (t: boolean, param: string | string) => T; // if we don't know for sure whether T is true or false
```

  In this example we can declaratively determine whether the function's second argument is a string or a number based on the first argument or fall back to a union type when we can't declaratively determine it(such as if a variable was passed which is on a runtime value)

  this syntax is runtime only and has it's own limitations so be warned.

  If you want to set a default type, you can do so with `= Type` such as `<T extends Array<any> = Array<any>>(t: T) => T` meaning that this function can take any array, and the generic type is now optional. Keep in mind that if you just specified the default type, it could still be provided an incompatible type if the `extends` is not used. `<T = Array<any>>(t: T) => T` will default to an `Array<any>` but will still accept any type.

<br />

### Type Predicates

if you need to narrow a type based on the existence of a property, or some other non-standard way that typescript isn't able to process, you can use a type-predicate to instruct typescript that the narrowing is valid.

See here for details: [https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates)

#### ⚠️ **This syntax is quite dangerous as you can instruct typescript of a type assertion that is not always valid. Use it sparingly and prefer writing types in a way that typescript can infer**

<br />

### Utility Types

Typescript has a wide-array of helpful Utility types which can be found here:
[https://www.typescriptlang.org/docs/handbook/utility-types.html](https://www.typescriptlang.org/docs/handbook/utility-types.html)

Some that may be of interest:

- `Omit<K, T>` remove `T` keys from `K` and return the type
- `Partial<T>` make all properties of `T` optional

### any/unknown/void/never types

Typescript has several meta-types for describing how much information is known about a type.

describing these types is a little difficult so I'll do my best but also point to the typescript handbook

[https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#any](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#any)  
[https://www.typescriptlang.org/docs/handbook/2/functions.html#other-types-to-know-about](https://www.typescriptlang.org/docs/handbook/2/functions.html#other-types-to-know-about)  
https://www.typescriptlang.org/docs/handbook/type-compatibility.html#any-unknown-object-void-undefined-null-and-never-assignability  

- `any` is the same as flow.
- `unknown` is effectively any but it cannot be used/assigned-to without being narrowed explicitly
- `object` effectively describes any type that is not a primitive
- `void` indicates the absence of a type?
- `undefined` is the type of undefined
- `null` is the type of null
- `never` indicates that a type is impossible to use. it can still be used with forced-casting but definitely shouldn't be

<br />

## Major Differences between Flow and Typescript

### Type Spreading

In flow we would write
  ```js
  type A = {|
    id: number
    data: string
  |};

  type B = {|
    ...A;
    newData: string;
  |};
  ```

  In typescript this syntax is not valid and we would instead write:
  ```ts
  type A = {
    id: number
    data: string
  };

  type B = A & {
    newData: string;
  };
  ```

  This uses an intersection to declare `B` must match both sides of the intersection. flow supported intersections but the practice was discouraged because they were sometimes unpredictable.

  #### **there is a notable exception to this translation**
  In flow, you could override a property with a later declaration or spread:

  ```js
  type A = {|
    id: number
    data?: string
  |};

  type B = {|
    ...A;
    data: string
  |};
  ```

  The codemod converts this syntax to:
  ```ts
  type A = {
    id: number
    data?: string
  };

  type B = A & {
    data: string;
  };
  ```

  **but this is not valid**
  The result of this is that the `B` type is `never` indicating it cannot be used. This is because you cannot satisfy a type with both `data: string` and `data?: string`.

  this doesn't work with interface types either.
  ```ts
  interface A {
    id: number
    data?: string
  }

  interface B extends A {
    data: string
  }
  ```

  However, unlike impossible intersections, this will just throw an error in the compiler which can be suppressed and the resulting type will contain `data: string` but this should not be relied-upon.

  Instead the code should be refactored to:
  ```ts
  type CommonProps = {
    id: number
  }

  type A = CommonProps & {
    data?: string
  }

  type B = CommonProps & {
    data: string
  }
  ```

### Record Types

In flow we would write
```js
type User = {|
  name: string;
  age: number;
|};

type UserMap = {[key: Key]: Value};
```

In typescript this is converted to
```ts
type User = {
  name: string;
  age: number;
};

type UserMap = Partial<Record<string, User>>;
```

for a few reasons.

1. typescript supports the `{[key: Key]: Value}` syntax but requires that the key-type is `string | symbol | number` whereas flow supported nearly anything as a key-type. typescript `Record<>` allows that the key-type need only extend `string | symbol | number` which is more permissive.
1. Airtable and Stripe claim that Flow implicitly sets the key-type as potentially undefined, but in my testing this hasn't been true. Nevertheless marking the the keys as optional is a good practice so we've proceeded with it anyways

### Optional Types and Optional Parameters

In flow we could use `?` to denote optional types and optional parameters but there were 2 different meanings with subtle differences:

#### Optional Types

in Flow an optional type can be denoted by prefixing it with a `?`:
```js
type A = {|
  a: ?string; // prop is required but could be null or undefined
|};
```

in typescript this syntax is not allowed and is instead replaced with a union type:
```ts
type A = {
  a: string | null | undefined;
};
```

#### Optional Parameters/Properties

This question mark could also be used to indicate an optional parameter or property:

```js
type A = {|
  a?: number;
|};

const f = (a?: number) => {};
```

In typescript this syntax is still allowed

```ts
type A = {
  a?: number;
};

const f = (a?: number) => {};
```

However theres a few caveats with this syntax with regards to function parameters
1. optional parameters may only appear at the end of the parameters list
1. optional parameters may not contain default values. a parameter may either be defaulted or optional, but not both

# Follow-ups

1. De-duplicating types for third-party modules(notably nsfw and nodegit)
1. Improving Parametric Selector support(or killing them entirely)
1. Fixing redux-saga's `dispatch` function type to support calling SagaGenerator functions(it was forced to `any` for the purposes of the migration)
1. removing every trace of flow from the codebase
1. enable `strictNullChecks` in the codebase
1. write documentation on converting larger branches

# More information

The original Stripe Flow-Migration Documentation: [./NOTES.md](./NOTES.md)  
Airtable's TypeScript Migration Documentation: [https://github.com/Airtable/TypeScript-migration-codemod#readme](https://github.com/Airtable/TypeScript-migration-codemod#readme)
