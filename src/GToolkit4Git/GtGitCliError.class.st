Class {
	#name : #GtGitCliError,
	#superclass : #Error,
	#instVars : [
		'stderr',
		'args',
		'exitCode'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliError >> args [
	^ args ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliError >> args: anObject [
	args := anObject
]

{ #category : #accessing }
GtGitCliError >> commandLine [
	^ Character space join: ({ 'git' } , self args)
]

{ #category : #accessing }
GtGitCliError >> errorLine [
	^ self stderr detect: [ :line | line beginsWith: 'ERROR' ] ifNone: [ nil ]
]

{ #category : #accessing }
GtGitCliError >> exitCode [
	^ exitCode
]

{ #category : #accessing }
GtGitCliError >> exitCode: anObject [
	exitCode := anObject
]

{ #category : #'gt extensions' }
GtGitCliError >> gtGitExitCodeFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Exitcode';
		priority: 40;
		text: [ self exitCode ifNil: [ 'no exit code' ] ]
]

{ #category : #accessing }
GtGitCliError >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Args';
		priority: 20;
		items: [ self args ]
]

{ #category : #accessing }
GtGitCliError >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Stderr';
		priority: 30;
		items: [ self stderr ]
]

{ #category : #'gt extensions' }
GtGitCliError >> gtGitSummaryFor: aView [
	<gtExceptionView>
	^ aView textEditor
		title: 'Git CLI failed';
		priority: 20;
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
GtGitCliError >> messageText [
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
GtGitCliError >> stderr [
	^ stderr ifNil: [ #() ]
]

{ #category : #accessing }
GtGitCliError >> stderr: anObject [
	stderr := anObject
]
