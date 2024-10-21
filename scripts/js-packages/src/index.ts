import qs, { BooleanOptional, IStringifyOptions } from "qs"

export class Bridge {
    static stringify(json: string) {
        const obj = JSON.parse(json);

        // default URI encode options
        const options: IStringifyOptions<BooleanOptional> = {
        }
        return qs.stringify(obj, options);
    }
}