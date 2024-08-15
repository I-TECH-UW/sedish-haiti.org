import { Model, FilterQuery, UpdateQuery, QueryOptions, SaveOptions } from 'mongoose';
export declare abstract class DAO<T> {
    protected readonly model: Model<T>;
    constructor(model: Model<T>);
    create(doc: Partial<T>, options?: SaveOptions): Promise<(import("mongoose").Document<unknown, {}, T> & {
        _id: import("mongoose").Types.ObjectId;
    }) | (import("mongoose").Document<unknown, {}, T> & {
        _id?: unknown;
    } & Required<{
        _id: unknown;
    }>)>;
    find(filter?: FilterQuery<T>, options?: QueryOptions): Promise<import("mongoose").Require_id<import("mongoose").FlattenMaps<T>>[]>;
    findOne(filter: FilterQuery<T>, options?: QueryOptions): Promise<import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> | (import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> extends infer T_1 ? T_1 extends import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> ? T_1 extends any[] ? import("mongoose").Require_id<import("mongoose").FlattenMaps<T>>[] : import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> : never : never) | (import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> extends infer T_2 ? T_2 extends import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> ? T_2 extends null ? import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> | (import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> extends infer T_1 ? T_1 extends import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> ? T_1 extends any[] ? import("mongoose").Require_id<import("mongoose").FlattenMaps<T>>[] : import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> : never : never) | null : import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> | (import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> extends infer T_1 ? T_1 extends import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> ? T_1 extends any[] ? import("mongoose").Require_id<import("mongoose").FlattenMaps<T>>[] : import("mongoose").Require_id<import("mongoose").FlattenMaps<T>> : never : never) : never : never) | null>;
    updateOne(filter: FilterQuery<T>, update: UpdateQuery<T>, options?: QueryOptions): Promise<import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> | null>;
    deleteOne(filter: FilterQuery<T>, options?: QueryOptions): Promise<import("mongoose").IfAny<T, any, import("mongoose").Document<unknown, {}, T> & import("mongoose").Require_id<T>> | null>;
}
