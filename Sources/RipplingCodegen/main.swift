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

// Code generator that looks up for any initializer with `Rippling<Value>` parameters in structs
// and emits a mirror initializer with `@escaping @autoclosure () -> Value` in place of every `Rippling<Value>`.
// These are for views and containers initializers.
//
// It also looks for any View extensions containing functions with rippling values and creates
// another View extension containing the same function with parameters replaced.
// These are for view modifiers.
// TODO: rewrite using Sourcery once guaranteed to work on all platforms?

/// Makes a simple attribute with only an identifier.
func makeSimpleAttribute(identifier: String) -> AttributeSyntax {
    return SyntaxFactory.makeAttribute(
        atSignToken: SyntaxFactory.makeAtSignToken(),
        attributeName: SyntaxFactory.makeIdentifier(identifier),
        leftParen: nil,
        argument: nil,
        rightParen: nil,
        tokenList: nil
    ).withTrailingTrivia(.spaces(1))
}

/// Rewriter for struct initializers and view modifiers functions.
class Rewriter: SyntaxRewriter {
    /// Rewriter for initializer declarations.
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

        // Get parameters list for the generated `init` call
        if let calledInitParameters = getCalledFunctionArguments(
            parameterList: node.parameters.parameterList,
            rewrittenParameters: initParameters
        ) {
            // First and only item in the body code block
            let item = SyntaxFactory.makeFunctionCallExpr(
                calledExpression: ExprSyntax(calledExpression),
                leftParen: SyntaxFactory.makeLeftParenToken(),
                argumentList: SyntaxFactory.makeTupleExprElementList(calledInitParameters),
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
                    ).withTrailingTrivia(.spaces(1)))
            )
        }
        else {
            return DeclSyntax(SyntaxFactory.makeBlankUnknownDecl())
        }
    }

    /// Creates parameters for the original called initializer or function (not the parameters of the
    /// generated function). Will return `nil` if no rippling parameter is found in the original function,
    /// in which case nothing should be emitted for that function.
    /// `parameterList` is the parameters list of the original function.
    /// `rewrittenParameters` is the list of rewritten parameters, aka the result of `rewriteParameters(parameterList)`.
    func getCalledFunctionArguments(
        parameterList: FunctionParameterListSyntax,
        rewrittenParameters: [FunctionParameterSyntax]
    ) -> [TupleExprElementSyntax]? {
        var foundRippling = false

        let list = zip(parameterList, rewrittenParameters.enumerated()).map { (originalParameter, rewrittenParameter) -> TupleExprElementSyntax in
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
                foundRippling = true

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
                colon: label != nil ? SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1)) : nil,
                expression: parameterExpression,
                trailingComma: index == parameterList.count - 1 ? nil : SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
            )
        }

        if !foundRippling {
            return nil
        }

        return list
    }

    /// Rewrites one function parameter to go from a rippling value to an escaping autoclosure.
    /// Other parameters are left untouched.
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
        var attributes = [AttributeSyntax]()
        attributes.append(makeSimpleAttribute(identifier: "escaping"))
        attributes.append(makeSimpleAttribute(identifier: "autoclosure"))

        let newType = SyntaxFactory.makeAttributedType(
            specifier: nil,
            attributes: SyntaxFactory.makeAttributeList(attributes.map { Syntax($0) }),
            baseType: TypeSyntax(SyntaxFactory.makeFunctionType(
                leftParen: SyntaxFactory.makeLeftParenToken(),
                arguments: SyntaxFactory.makeBlankTupleTypeElementList(),
                rightParen: SyntaxFactory.makeRightParenToken().withTrailingTrivia(.spaces(1)),
                asyncKeyword: nil,
                throwsOrRethrowsKeyword: nil,
                arrow: SyntaxFactory.makeArrowToken().withTrailingTrivia(.spaces(1)),
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
                        equal: SyntaxFactory.makeEqualToken().withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1)),
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
            colon: SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1)),
            type: TypeSyntax(newType),
            ellipsis: nil,
            defaultArgument: defaultArgument,
            trailingComma: node.trailingComma
        )

        return newParameter
    }

    /// Rewriter for function declarations. Used to rewrite view modifiers.
    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        // Rewrite parameters to change from `Rippling` to escaping autoclosures
        let funcParameters = node.signature.input.parameterList.map { self.rewriteParameter($0) }

        // Rewrite the body to call the original function
        let calledExpression = SyntaxFactory.makeMemberAccessExpr(
            base: ExprSyntax(SyntaxFactory.makeIdentifierExpr(identifier: SyntaxFactory.makeSelfKeyword(), declNameArguments: nil)),
            dot: SyntaxFactory.makePeriodToken(),
            name: node.identifier,
            declNameArguments: nil
        )

        // Get parameters list for the generated function call
        if let calledInitParameters = getCalledFunctionArguments(
            parameterList: node.signature.input.parameterList,
            rewrittenParameters: funcParameters
        ) {
            // First and only item in the body code block
            let item = SyntaxFactory.makeFunctionCallExpr(
                calledExpression: ExprSyntax(calledExpression),
                leftParen: SyntaxFactory.makeLeftParenToken(),
                argumentList: SyntaxFactory.makeTupleExprElementList(calledInitParameters),
                rightParen: SyntaxFactory.makeRightParenToken(),
                trailingClosure: nil,
                additionalTrailingClosures: nil
            )

            // Return statement
            let returnStatement = SyntaxFactory.makeReturnStmt(
                returnKeyword: SyntaxFactory.makeReturnKeyword().withTrailingTrivia(.spaces(1)),
                expression: ExprSyntax(item)
            )

            // Statement for that item
            let statement = SyntaxFactory.makeCodeBlockItem(
                item: Syntax(returnStatement),
                semicolon: nil,
                errorTokens: nil
            ).withLeadingTrivia(Trivia(pieces: [.newlines(1), .spaces(8)]))

            return DeclSyntax(
                node
                    // Rewrite body to use our new code block
                    .withBody(
                        SyntaxFactory.makeCodeBlock(
                            leftBrace: SyntaxFactory.makeLeftBraceToken(),
                            statements: SyntaxFactory.makeCodeBlockItemList([statement]),
                            rightBrace: SyntaxFactory.makeRightBraceToken().withLeadingTrivia(Trivia(pieces: [.newlines(1), .spaces(4)]))
                        )
                    ).withTrailingTrivia(.newlines(2))
                    // Rewrite parameters to use our new list
                    .withSignature(
                        node.signature.withInput(SyntaxFactory.makeParameterClause(
                            leftParen: SyntaxFactory.makeLeftParenToken(),
                            parameterList: SyntaxFactory.makeFunctionParameterList(funcParameters),
                            rightParen: SyntaxFactory.makeRightParenToken()
                        ).withTrailingTrivia(.spaces(1)))
                    )
            )
        }
        else {
            return DeclSyntax(SyntaxFactory.makeBlankUnknownDecl())
        }
    }
}

enum VisitorState {
    case idle
    case visitingStruct
    case visitingViewExtension
}

class Visitor: SyntaxVisitor {
    let rewriter = Rewriter()

    var state = VisitorState.idle

    /// Extension currently being generated.
    var currentExtension: ExtensionDeclSyntax?

    /// Generated extensions.
    var generatedExtensions = [ExtensionDeclSyntax]()

    /// Visitor for structures.
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Create a new generated extension for that struct
        // Default members list is `nil` which causes issues later in the program
        self.currentExtension = self.makeGeneratedExtension(
            extendedType: TypeSyntax(
                SyntaxFactory.makeSimpleTypeIdentifier(name: node.identifier, genericArgumentClause: nil)
            ).withTrailingTrivia(.spaces(1)),
            modifiers: node.modifiers
        )
        self.state = .visitingStruct

        return .visitChildren
    }

    /// Called after structs and their children are visited.
    override func visitPost(_ node: StructDeclSyntax) {
        // Add the newly generated extension to the list
        if let ext = self.currentExtension {
            self.generatedExtensions.append(ext)
        }

        // We are finished visiting the struct, clear our state
        self.currentExtension = nil
        self.state = .idle
    }

    /// Visitor for initializers.
    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        // Only care about struct initializers
        if self.state != .visitingStruct {
            return .skipChildren
        }

        // Call the rewriter to get the new `init` and add it to our extension.
        // Having `nil` here means the rewriter gave us an "unknown decl syntax", which means "don't
        // generate any initializer".
        if var newInit = self.rewriter.visit(node).as(InitializerDeclSyntax.self) {
            // Remove any modifiers that's already in the extension declaration
            newInit.modifiers = self.makeGeneratedFunctionModifiers(newFuncModifiers: newInit.modifiers)

            // Add it to members
            let member = SyntaxFactory.makeMemberDeclListItem(decl: DeclSyntax(newInit), semicolon: nil)
            if let newMembers = self.currentExtension?.members.members.appending(member) {
                self.currentExtension?.members.members = newMembers
            }
        }

        return .skipChildren
    }

    /// Visitor for extensions.
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        // Only visit extensions of `View` (assume it's the Ripple `View` type)
        if node.extendedType.as(SimpleTypeIdentifierSyntax.self)?.name.withoutTrivia().text != "View" {
            return .skipChildren
        }

        // Create a new generated extension for that extension
        self.currentExtension = self.makeGeneratedExtension(
            extendedType: node.extendedType,
            modifiers: node.modifiers
        )
        self.state = .visitingViewExtension

        return .visitChildren
    }

    /// Called after extensions and their children are visited.
    override func visitPost(_ node: ExtensionDeclSyntax) {
        // Add the newly generated extension to the list
        if let ext = self.currentExtension {
            self.generatedExtensions.append(ext)
        }

        // We are finished visiting the extension, clear our state
        self.currentExtension = nil
        self.state = .idle
    }

    /// Visitor for functions.
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        // Only care about view extensions functions
        if self.state != .visitingViewExtension {
            return .skipChildren
        }

        // Call the rewriter to get the new function and add it to our extension.
        // Having `nil` here means the rewriter gave us an "unknown decl syntax", which means "don't
        // generate any function".
        if var newFunction = self.rewriter.visit(node).as(FunctionDeclSyntax.self) {
            // Remove any modifiers that's already in the extension declaration
            newFunction.modifiers = self.makeGeneratedFunctionModifiers(newFuncModifiers: newFunction.modifiers)

            // Remove func keyword trivia for documentation blocks
            newFunction = newFunction.withFuncKeyword(
                SyntaxFactory.makeFuncKeyword().withTrailingTrivia(.spaces(1))
            )

            // Add it to members
            let member = SyntaxFactory.makeMemberDeclListItem(decl: DeclSyntax(newFunction), semicolon: nil)
            if let newMembers = self.currentExtension?.members.members.appending(member) {
                self.currentExtension?.members.members = newMembers
            }
        }

        return .skipChildren
    }

    /// Takes a generated function or initializer and the generated extension it will go in,
    /// and removes from the function every modifier that is also in its surrounding extension.
    func makeGeneratedFunctionModifiers(newFuncModifiers: ModifierListSyntax?) -> ModifierListSyntax {
        return SyntaxFactory.makeModifierList((newFuncModifiers ?? SyntaxFactory.makeBlankModifierList()).filter { modifier in
            // If the extension does not have any modifier, keep it from the function
            guard let extModifiers = self.currentExtension?.modifiers else {
                return true
            }

            return !(
                extModifiers
                    .map { $0.name.text.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .contains(modifier.name.text.trimmingCharacters(in: .whitespacesAndNewlines))
            )
        })
    }

    /// Creates a new generated extension declaration.
    func makeGeneratedExtension(extendedType: TypeSyntax, modifiers: ModifierListSyntax?) -> ExtensionDeclSyntax {
        // Default members list is `nil` which causes issues later in the program
        return SyntaxFactory.makeExtensionDecl(
            attributes: nil,
            modifiers: modifiers?.withoutTrivia().withTrailingTrivia(.spaces(1)), // remove trivia for documentation blocks
            extensionKeyword: SyntaxFactory.makeExtensionKeyword().withTrailingTrivia(.spaces(1)),
            extendedType: extendedType,
            inheritanceClause: nil,
            genericWhereClause: nil,
            members: SyntaxFactory.makeMemberDeclBlock(
                leftBrace: SyntaxFactory.makeLeftBraceToken().withTrailingTrivia(Trivia.newlines(1)),
                members: SyntaxFactory.makeMemberDeclList([]),
                rightBrace: SyntaxFactory.makeRightBraceToken().withLeadingTrivia(Trivia.newlines(1))
            )
        ).withTrailingTrivia(Trivia.newlines(2))
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

    for ext in visitor.generatedExtensions {
        // If there are no members, don't add the extension
        if ext.members.members.isEmpty {
            continue
        }

        content += String(describing: ext)
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

