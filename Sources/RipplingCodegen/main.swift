/*
    Copyright 2021 natinusala

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

import Foundation

import SwiftSyntax
import SwiftSyntaxParser
import TSCBasic

/// Code generator that looks up for any initializer with `Rippling<Value>` parameters in structs
/// and emits a mirror initializer with `@escaping @autoclosure () -> Value` in place of every `Rippling<Value>`.

/// Makes a simple attribute with only an identifier.
func makeSimpleAttribute(identifier: String) -> AttributeSyntax {
    return SyntaxFactory.makeAttribute(
        atSignToken: SyntaxFactory.makeAtSignToken(),
        attributeName: SyntaxFactory.makeIdentifier(identifier),
        leftParen: nil,
        argument: nil,
        rightParen: nil,
        tokenList: nil
    ).withTrailingTrivia(Trivia(pieces: [.spaces(1)]))
}

class InitRewriter: SyntaxRewriter {
    /// Visitor for initializer declarations.
    override func visit(_ node: InitializerDeclSyntax) -> DeclSyntax {
        // Rewrite parameters to change from `Rippling` to escaping autoclosures
        let initParameters = node.parameters.parameterList.map { self.rewriteParameter($0) }

        // Rewrite the body to call the original `init`
        let calledExpression = SyntaxFactory.makeMemberAccessExpr(
            base: ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: SyntaxFactory.makeSelfKeyword(), declNameArguments: nil)),
            dot: SyntaxFactory.makePeriodToken(),
            name: SyntaxFactory.makeInitKeyword(),
            declNameArguments: nil
        )

        // Only generate an initializer if there is at least one `Rippling` parameter
        var generateInit = false

        // Parameters list for the generated `init` call
        let parameters: [TupleExprElementSyntax] = zip(node.parameters.parameterList, initParameters.enumerated()).map { (originalParameter, rewrittenParameter) in
            let index = rewrittenParameter.0
            let element = rewrittenParameter.1

            // Create the parameter label
            var label: TokenSyntax?

            // No underscore = we need a label
            if element.firstName?.text != "_" {
                // If there is a second name, use it
                if element.secondName != nil {
                    label = element.secondName
                }

                // Otherwise use the first name
                label = element.firstName
            }

            var parameterExpression: ExprSyntax

            guard let identifier = element.secondName ?? element.firstName else {
                return SyntaxFactory.makeBlankTupleExprElement()
            }

            label = label?.withoutTrivia()

            // Wrap the parameter in a `Rippling<Value>(param())` expression if the parameter is a rippling in the
            // called initializer, otherwise leave it unchanged (pass it through).
            // The parenthesis after `param` are for autoclosure forwarding.

            // The original parameter already has the right type so we can reuse it
            let calledType = originalParameter.type?.as(SimpleTypeIdentifierSyntax.self)

            if calledType?.name.text == "Rippling" {
                generateInit = true

                // Autoclosure forwarding: parameter followed by `()`
                let autoclosureForwarding = SyntaxFactory.makeFunctionCallExpr(
                    calledExpression: ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: identifier, declNameArguments: nil)),
                    leftParen: SyntaxFactory.makeLeftParenToken(),
                    argumentList: SyntaxFactory.makeBlankTupleExprElementList(),
                    rightParen: SyntaxFactory.makeRightParenToken(),
                    trailingClosure: nil,
                    additionalTrailingClosures: nil
                )

                // Argument of the call: `Rippling<Value>(-> parameter() <-)`
                let parameterArgument = SyntaxFactory.makeTupleExprElement(
                    label: nil,
                    colon: nil,
                    expression: ExprSyntax(autoclosureForwarding),
                    trailingComma: nil
                )

                // Expression for the parameter (the whole `Rippling<Value>(param)` expression)
                parameterExpression = ExprSyntax(SyntaxFactory.makeFunctionCallExpr(
                    calledExpression: ExprSyntax(SyntaxFactory.makeTypeExpr(type: TypeSyntax(calledType!))),
                    leftParen: SyntaxFactory.makeLeftParenToken(),
                    argumentList: SyntaxFactory.makeTupleExprElementList([parameterArgument]),
                    rightParen: SyntaxFactory.makeRightParenToken(),
                    trailingClosure: nil,
                    additionalTrailingClosures: nil
                ))
            } else {
                parameterExpression = ExprSyntax(
                    SyntaxFactory.makeIdentifierExpr(
                        identifier: SyntaxFactory.makeIdentifier(identifier.text),
                        declNameArguments: nil
                    )
                )
            }

            return SyntaxFactory.makeTupleExprElement(
                label: label,
                colon: label != nil ? SyntaxFactory.makeColonToken().withTrailingTrivia(Trivia(pieces: [.spaces(1)])) : nil,
                expression: parameterExpression,
                trailingComma: index == initParameters.count - 1 ? nil : SyntaxFactory.makeCommaToken().withTrailingTrivia(Trivia(pieces: [.spaces(1)]))
            )
        }

        // First and only item in the body code block
        let item = SyntaxFactory.makeFunctionCallExpr(
            calledExpression: ExprSyntax(calledExpression),
            leftParen: SyntaxFactory.makeLeftParenToken(),
            argumentList: SyntaxFactory.makeTupleExprElementList(parameters),
            rightParen: SyntaxFactory.makeRightParenToken(),
            trailingClosure: nil,
            additionalTrailingClosures: nil
        )

        // Statement for that item
        let statement = SyntaxFactory.makeCodeBlockItem(
            item: Syntax(item),
            semicolon: nil,
            errorTokens: nil
        ).withLeadingTrivia(Trivia(pieces: [.newlines(1), .spaces(8)]))

        if generateInit {
            // TODO: remove any comment block from the initializer
            return DeclSyntax(
                node
                    // Rewrite body to use our new code block
                    .withBody(
                        SyntaxFactory.makeCodeBlock(
                            leftBrace: SyntaxFactory.makeLeftBraceToken(),
                            statements: SyntaxFactory.makeCodeBlockItemList([statement]),
                            rightBrace: SyntaxFactory.makeRightBraceToken().withLeadingTrivia(Trivia(pieces: [.newlines(1), .spaces(4)]))
                        )
                    )
                    // Rewrite parameters to use our new list
                    .withParameters(SyntaxFactory.makeParameterClause(
                        leftParen: SyntaxFactory.makeLeftParenToken(),
                        parameterList: SyntaxFactory.makeFunctionParameterList(initParameters),
                        rightParen: SyntaxFactory.makeRightParenToken()
                    ).withTrailingTrivia(Trivia(pieces: [.spaces(1)])))
            )
        }
        else {
            return DeclSyntax(SyntaxFactory.makeBlankUnknownDecl())
        }
    }

    /// Rewrites one initializer parameter.
    func rewriteParameter(_ node: FunctionParameterSyntax) -> FunctionParameterSyntax {
        guard let type = node.type?.as(SimpleTypeIdentifierSyntax.self) else {
            return node
        }

        // Only rewrite `Rippling` parameters with one generic argument
        if type.name.text != "Rippling" {
            return node
        }

        guard let genericArguments = type.genericArgumentClause?.arguments else {
            return node
        }

        if genericArguments.count != 1 {
            return node
        }

        let ripplingType = genericArguments.first!.argumentType

        // Rewrite type from `Rippling<Value>` to `() -> Value` + add `@escaping @autoclosure` attributes
        var attributes: [AttributeSyntax] = []
        attributes.append(makeSimpleAttribute(identifier: "escaping"))
        attributes.append(makeSimpleAttribute(identifier: "autoclosure"))

        let newType = SyntaxFactory.makeAttributedType(
            specifier: nil,
            attributes: SyntaxFactory.makeAttributeList(attributes.map { Syntax($0) }),
            baseType: TypeSyntax(SyntaxFactory.makeFunctionType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                arguments: SyntaxFactory.makeBlankTupleTypeElementList(),
                rightParen: SyntaxFactory.makeRightParenToken().withTrailingTrivia(Trivia(pieces: [.spaces(1)])),
                asyncKeyword: nil,
                throwsOrRethrowsKeyword: nil,
                arrow: SyntaxFactory.makeArrowToken().withTrailingTrivia(Trivia(pieces: [.spaces(1)])),
                returnType: ripplingType
            ))
        )

        // If the parameter has a default value in the form of `= .init(xxx)`, extract `xxx`
        // and use it as the default value for our generated parameter
        var defaultArgument: InitializerClauseSyntax? = nil

        if let originalFunctionCall = node.defaultArgument?.value.as(FunctionCallExprSyntax.self) {
            // Make sure the default value is an `init` call
            if originalFunctionCall.withoutTrivia().calledExpression.as(MemberAccessExprSyntax.self)?.name.text == "init" {
                // Extract the first argument of the call
                if let argument = originalFunctionCall.argumentList.first {
                    // Create the new default argument
                    defaultArgument = SyntaxFactory.makeInitializerClause(
                        equal: SyntaxFactory.makeEqualToken().withLeadingTrivia(Trivia(pieces: [.spaces(1)])).withTrailingTrivia(Trivia(pieces: [.spaces(1)])),
                        value: argument.expression
                    )
                }
            }
        }

        // Return a new parameter with the right type
        let newParameter = SyntaxFactory.makeFunctionParameter(
            attributes: SyntaxFactory.makeBlankAttributeList(),
            firstName: node.firstName,
            secondName: node.secondName,
            colon: SyntaxFactory.makeColonToken().withTrailingTrivia(Trivia(pieces: [.spaces(1)])),
            type: TypeSyntax(newType),
            ellipsis: nil,
            defaultArgument: defaultArgument,
            trailingComma: node.trailingComma
        )

        return newParameter
    }
}

class Visitor: SyntaxVisitor {
    let rewriter = InitRewriter()

    var currentStruct: StructDeclSyntax?

    /// Generated initializers for every visited struct.
    var generatedInitializers: [StructDeclSyntax: [InitializerDeclSyntax]] = [:]

    /// Visitor for structures.
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Store the struct as the "current" one.
        self.currentStruct = node

        return .visitChildren
    }

    /// Called after structs and its children are visited.
    override func visitPost(_ node: StructDeclSyntax) {
        // We are finished visiting the struct, clear our state
        self.currentStruct = nil
    }

    /// Visitor for initializers.
    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        // Only visit initializers of structs that we care about
        guard let currentStruct = self.currentStruct else {
            return .skipChildren
        }

        // Call the rewriter visitor to get the new `init` and add it to the list
        // Having `nil` here means the rewriter gave us an "unknown decl syntax", which means "don't
        // generate any initializer"
        if let newInit = rewriter.visit(node).as(InitializerDeclSyntax.self) {
            if var list = self.generatedInitializers[currentStruct] {
                list.append(newInit)
            } else {
                self.generatedInitializers[currentStruct] = [newInit]
            }
        }



        return .skipChildren
    }
}

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = AbsolutePath(CommandLine.arguments[2])

// XXX: RippleUI cannot import `Ripple` so import `RippleCore` first, then `Ripple` if it fails
var content: String = "#if canImport(RippleCore)\nimport RippleCore\n#else\nimport Ripple\n#endif\n\n"

do {
    let src = try SyntaxParser.parse(input)

    let visitor = Visitor()
    visitor.walk(src)

    for (structDecl, inits) in visitor.generatedInitializers {
        // If there are no initializers, don't add the extension
        if inits.count == 0 {
            continue
        }

        // Copy modifiers from original struct (access level...)
        var modifiers = ""

        if let originalModifiers = structDecl.modifiers {
            modifiers = String(describing: originalModifiers.withoutTrivia()) // remove trivia for documentation blocks
        }

        content += "\(modifiers) extension \(structDecl.identifier.text) {\n"
        for var initializer in inits {
            // If the initializer access level is the same as the extension one, remove it from the initializer
            // to prevent emitting "xxx modifier is redundant for initializers declared in a xxx extension" warnings

            let newModifiers: [DeclModifierSyntax] = initializer.modifiers?.withoutTrivia().filter {
                !( // only keep those that are not contained in both lists
                    structDecl.modifiers?.withoutTrivia()
                        .map({ $0.name.text.trimmingCharacters(in: .whitespacesAndNewlines) })
                        .contains($0.name.text.trimmingCharacters(in: .whitespacesAndNewlines)) ?? false // in case there are no modifiers in the struct
                )
            } ?? [] // in case there are no modifiers in the initializer
            initializer = initializer.withModifiers(SyntaxFactory.makeModifierList(newModifiers).withTrailingTrivia(Trivia(pieces: [.spaces(1)])))

            content += "    " + String(describing: initializer) + "\n"
        }
        content += "}"
    }
} catch {
    // If anything fails, emit a diagnostic message and
    // write an empty file in output to prevent the rest of the compilation
    // to fail (we want the user to see the rest of the compilation errors since their Swift
    // files are probably ill-formed).
    print("Error when generating rippling extensions for \(input.absoluteString): \(error)")
    content = "// ERROR: \(error)"
}

try! content.write(toFile: output.pathString, atomically: false, encoding: .utf8)

