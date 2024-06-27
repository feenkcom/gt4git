Class {
	#name : #GtGitCliCommandError,
	#superclass : #GtGitError,
	#instVars : [
		'stderr',
		'args',
		'exitCode'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GtGitCliCommandError >> args [
	^ args ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliCommandError >> args: anObject [
	args := anObject
]

{ #category : #accessing }
GtGitCliCommandError >> commandLine [
	^ Character space join: ({ 'git' } , self args)
]

{ #category : #accessing }
GtGitCliCommandError >> errorLine [
	^ self stderr detect: [ :line | line beginsWith: 'ERROR' ] ifNone: [ nil ]
]

{ #category : #accessing }
GtGitCliCommandError >> exitCode [
	^ exitCode
]

{ #category : #accessing }
GtGitCliCommandError >> exitCode: anObject [
	exitCode := anObject
]

{ #category : #'gt extensions' }
GtGitCliCommandError >> gtGitExitCodeFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Exitcode';
		priority: 40;
		text: [ self exitCode ifNil: [ 'no exit code' ] ]
]

{ #category : #accessing }
GtGitCliCommandError >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Args';
		priority: 20;
		items: [ self args ]
]

{ #category : #accessing }
GtGitCliCommandError >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Stderr';
		priority: 30;
		items: [ self stderr ]
]

{ #category : #'gt extensions' }
GtGitCliCommandError >> gtGitSummaryFor: aView [
	<gtExceptionView>
	^ aView textEditor
		title: 'Git CLI failed';
		priority: 20;
		aptitude: BrGlamorousCodeEditorAptitude;
		text: [ 
			String streamContents: [ :out |
				out 
					nextPutAll: self commandLine;
					nextPutAll: ' failed.';
					cr;
					cr.
				self stderr do: [ :line |
					out nextPutAll: line; cr ] ] ]
]

{ #category : #accessing }
GtGitCliCommandError >> messageText [
	^ messageText ifNil: [ 
		messageText := String streamContents: [ :out |
			out 
				nextPutAll: self commandLine;
				nextPutAll: ' failed.'.
			self errorLine ifNotNil: [ :line | 
				out 
					space; 
					nextPutAll: self errorLine ] ] ]
]

{ #category : #accessing }
GtGitCliCommandError >> stderr [
	^ stderr ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliCommandError >> stderr: anObject [
	stderr := anObject
]
