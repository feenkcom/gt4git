Class {
	#name : #GtGitCliEvent,
	#superclass : #GtBeaconLogEvent,
	#category : #'GToolkit4Git-Libgit-CLI-GT'
}

{ #category : #accessing }
GtGitCliEvent class >> eventLabel [
	^'Git Cli Event'
]

{ #category : #accessing }
GtGitCliEvent >> args [
	^ self eventStartedSignal args
]

{ #category : #acccessing }
GtGitCliEvent >> eventLabel [
	^ 'git ' , self operation asString 
]

{ #category : #accessing }
GtGitCliEvent >> firstArg [
	| args |
	args := self args.
	^ args isEmpty
		ifTrue: [ nil ]
		ifFalse: [ args first ]
]

{ #category : #'gt extensions' }
GtGitCliEvent >> gtGitHelpFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Git help';
		priority: 7;
		text: [ | command |
			command := self firstArg.
			command
				ifNil: [ '' ]
				ifNotNil: [ IceGitCliPlatform current executor gitHelpFor: command ] ]
]

{ #category : #'gt extensions' }
GtGitCliEvent >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Git call';
		priority: 5;
		items: [ 
			self eventCompletedSignal hasOutput
				ifTrue: [
					{ self operation . '' } , self args , #('' '=>' '') , self output ] 
				ifFalse: [ self args ] ]
]

{ #category : #'gt extensions' }
GtGitCliEvent >> gtStackFor: aView [
	<gtView>
	^ aView list
		title: 'Stack';
		priority: 45;
		items: [  self stack ]
]

{ #category : #accessing }
GtGitCliEvent >> operation [
	^ self eventStartedSignal operation
]

{ #category : #accessing }
GtGitCliEvent >> output [
	^ self eventCompletedSignal output
]

{ #category : #accessing }
GtGitCliEvent >> restArgs [
	| args |
	args := self args.
	^ args isEmpty
		ifTrue: [ #() ]
		ifFalse: [ args allButFirst ]
]

{ #category : #accessing }
GtGitCliEvent >> stack [
	^ self eventStartedSignal stack
]
