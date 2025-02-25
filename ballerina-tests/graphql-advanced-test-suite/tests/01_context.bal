// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/graphql;
import ballerina/graphql_test_common as common;
import ballerina/http;
import ballerina/test;

@test:Config {
    groups: ["context"]
}
function testSettingAttribute() returns error? {
    graphql:ContextInit contextInit =
        isolated function(http:RequestContext requestContext, http:Request request) returns graphql:Context|error {
        graphql:Context context = new;
        context.set("String", "Ballerina");
        return context;
    };
    http:Request request = new;
    http:RequestContext requestContext = new;
    graphql:Context context = check contextInit(requestContext, request);
    var value = check context.get("String");
    test:assertTrue(value is string);
    test:assertEquals(<string>value, "Ballerina");
}

@test:Config {
    groups: ["context"]
}
function testSettingAttributeTwice() returns error? {
    graphql:ContextInit contextInit =
        isolated function(http:RequestContext requestContext, http:Request request) returns graphql:Context|error {
        graphql:Context context = new;
        context.set("String", "Ballerina");
        return context;
    };
    http:Request request = new;
    http:RequestContext requestContext = new;
    graphql:Context context = check contextInit(requestContext, request);
    var value = check context.get("String");
    test:assertTrue(value is string);
    test:assertEquals(<string>value, "Ballerina");

    context.set("String", "GraphQL");
    value = check context.get("String");
    test:assertTrue(value is string);
    test:assertEquals(<string>value, "GraphQL");
}

@test:Config {
    groups: ["context"]
}
function testSettingObjectValues() returns error? {
    graphql:ContextInit contextInit =
        isolated function(http:RequestContext requestContext, http:Request request) returns graphql:Context|error {
        graphql:Context context = new;
        context.set("HierarchicalServiceObject", new HierarchicalName());
        return context;
    };
    http:Request request = new;
    http:RequestContext requestContext = new;
    graphql:Context context = check contextInit(requestContext, request);
    test:assertTrue((check context.get("HierarchicalServiceObject")) is HierarchicalName);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithHttpHeaderValues() returns error? {
    string url = "http://localhost:9090/context";
    string document = "{ profile { name } }";
    http:Request request = new;
    request.setHeader("scope", "admin");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        data: {
            profile: {
                name: "Walter White"
            }
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithAdditionalParameters() returns error? {
    string url = "http://localhost:9090/context";
    string document = string `{ name(name: "Jesse Pinkman") }`;
    http:Request request = new;
    request.setHeader("scope", "admin");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        data: {
            name: "Jesse Pinkman"
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithHttpHeaderValuesWithInvalidScope() returns error? {
    string url = "http://localhost:9090/context";
    string document = "{ profile { name } }";
    http:Request request = new;
    request.setHeader("scope", "user");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        errors: [
            {
                message: "You don't have permission to retrieve data",
                locations: [
                    {
                        line: 1,
                        column: 3
                    }
                ],
                path: [
                    "profile"
                ]
            }
        ],
        data: null
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithHttpHeaderValuesInRemoteFunction() returns error? {
    string url = "http://localhost:9090/context";
    string document = "mutation { update { name } }";
    http:Request request = new;
    request.setHeader("scope", "admin");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        data: {
            update: [
                {
                    name: "Sherlock Holmes"
                },
                {
                    name: "Walter White"
                },
                {
                    name: "Tom Marvolo Riddle"
                }
            ]
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithHttpHeaderValuesInRemoteFunctionWithInvalidScope() returns error? {
    string url = "http://localhost:9090/context";
    string document = "mutation { update { name } }";
    http:Request request = new;
    request.setHeader("scope", "user");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        errors: [
            {
                message: "You don't have permission to retrieve data",
                locations: [
                    {
                        line: 1,
                        column: 12
                    }
                ],
                path: ["update", 1]
            }
        ],
        data: null
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testNullableArrayElementValuesWithError() returns error? {
    string url = "http://localhost:9090/context";
    string document = "mutation { updateNullable { name } }";
    http:Request request = new;
    request.setHeader("scope", "user");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        errors: [
            {
                message: "You don't have permission to retrieve data",
                locations: [
                    {
                        line: 1,
                        column: 12
                    }
                ],
                path: ["updateNullable", 1]
            }
        ],
        data: {
            updateNullable: [
                {
                    name: "Sherlock Holmes"
                },
                null,
                {
                    name: "Tom Marvolo Riddle"
                }
            ]
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithMissingAttribute() returns error? {
    string url = "http://localhost:9090/context";
    string document = "mutation { update { name } }";
    json actualPayload = check common:getJsonPayloadFromService(url, document);
    json expectedPayload = {
        errors: [
            {
                message: "Http header does not exist"
            }
        ]
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithAdditionalParametersInNestedObject() returns error? {
    string url = "http://localhost:9090/context";
    string document = string `{ animal { call(sound: "Meow", count: 3) } }`;
    http:Request request = new;
    request.setHeader("scope", "admin");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        data: {
            animal: {
                call: "Meow Meow Meow "
            }
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["context"]
}
isolated function testContextWithAdditionalParametersInNestedObjectWithInvalidScope() returns error? {
    string url = "http://localhost:9090/context";
    string document = string `{ animal { call(sound: "Meow", count: 3) } }`;
    http:Request request = new;
    request.setHeader("scope", "user");
    request.setPayload({query: document});
    json actualPayload = check common:getJsonPayloadFromRequest(url, request);
    json expectedPayload = {
        data: {
            animal: {
                call: "Meow"
            }
        }
    };
    common:assertJsonValuesWithOrder(actualPayload, expectedPayload);
}
