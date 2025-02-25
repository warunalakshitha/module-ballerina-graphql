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

import ballerina/graphql_test_common as common;
import ballerina/test;

@test:Config {
    groups: ["block_strings"],
    dataProvider: dataProviderBlockString
}
isolated function testBlockStrings(string resourceFileName) returns error? {
    string url = "http://localhost:9091/inputs";
    string document = check common:getGraphqlDocumentFromFile(resourceFileName);
    json actualPayload = check common:getJsonPayloadFromService(url, document);
    json expectedPayload = check common:getJsonContentFromFile(resourceFileName);
    test:assertEquals(actualPayload, expectedPayload);
}

function dataProviderBlockString() returns string[][] {
    return [
        ["block_strings"],
        ["block_strings_with_variable_default_value"],
        ["invalid_block_strings"],
        ["block_strings_with_escaped_character"],
        ["block_strings_with_double_quotes"],
        ["empty_block_string"],
        ["empty_string"]
    ];
}
