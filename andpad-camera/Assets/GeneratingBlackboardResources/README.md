# Blackboard component for Native app

This library provides a blackboard component to native apps.

Build [the svelte component](https://github.com/88labs/andpad-blackboard-web-components) into a single html file with [vite-plugin-singlefile](https://github.com/richardtallent/vite-plugin-singlefile).

The font files are placed in a public dir as static files.

## How to Use

### Parameter

Access index.html with the query parameter.

The query parameter is converted to a javascript object using the [qs](https://github.com/ljharb/qs) package and passed to the blackboard component.

See `src/types/blackboard.d.ts` for detailed types.
ref. https://github.com/88labs/andpad-blackboard-web-components/tree/c55e33e86f402befecc94c8942f24616806e7fbf/packages/andpad-blackboard-svelte-components/src/types

```ts
import type {
  Order,
  Blackboard,
} from "@88labs/andpad-blackboard-svelte-components";

export type BlackboardProps = {
  order: Order;
  blackboard: Blackboard;
  color: "black" | "white" | "green";
  scale: number;
  miniatureMapError: Function;
  characterWidthRatio: number;
  isShowEmptyMiniatureMap: boolean;
  isHiddenNoneAndEmptyMiniatureMap: boolean;
  remarkHorizontalAlign: "left" | "center" | "right";
  remarkTextSize: "small" | "medium" | "large";
  remarkVerticalAlign: "top" | "middle" | "bottom";
  firstRowBlackboardItemBodyType: "initial_value" | "custom";
  firstRowBlackboardItemBody: string;
  opacity: 0 | 0.5 | 1;
  isEdged: boolean;
};
```

### Event

Window dispatch custom events

1. mounted event

```ts
interface CustomEvent {
  type: "mounted";
}
```

2. miniature-map-change event

```ts
interface CustomEvent {
  type: "miniature-map-change";
  detail:
    | "unsupported"
    | "processing"
    | "loading"
    | "loaded"
    | "errored"
    | "none"
    | "empty"
    | "hidden";
}
```

## How to Develop

### 1. Setting GitHub's Personal Access Token (PAT)

To access private packages from the package manager, you need to setup Github PAT before running `yarn install`

1. Generate [PAT](https://github.com/settings/tokens). Make sure to check `repo` and `read:packages` as below.
   ![スクリーンショット 2021-12-24 15 11 04](https://user-images.githubusercontent.com/11626807/147324361-4b16d6f5-5a4a-49b2-800e-f18cc5c29ed9.png)

2. Create a file `.npmrc` under repository root with the token issued above.

```
//npm.pkg.github.com/:_authToken="<github_personal_access_token>"
@88labs:registry=https://npm.pkg.github.com
```

### 2. Start dev server

- `npm run dev` command starts the development server
- `npm run build` command generates production build in `dist` directory
