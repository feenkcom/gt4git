Extension { #name : #GtGitCliCommandError }

{ #category : #'*GToolkit4Git' }
GtGitCliCommandError >> gtGitExitCodeFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Exitcode';
		priority: 40;
		text: [ self exitCode ifNil: [ 'no exit code' ] ]
]

{ #category : #'*GToolkit4Git' }
GtGitCliCommandError >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Args';
		priority: 20;
		items: [ self args ]
]

{ #category : #'*GToolkit4Git' }
GtGitCliCommandError >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Stderr';
		priority: 30;
		items: [ self stderr ]
]

{ #category : #'*GToolkit4Git' }
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
