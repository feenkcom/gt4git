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
GtGitCliEvent >> stack [
	^ self eventStartedSignal stack
]
