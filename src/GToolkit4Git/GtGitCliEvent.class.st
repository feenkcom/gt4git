Class {
	#name : #GtGitCliEvent,
	#superclass : #GtBeaconLogEvent,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliEvent class >> eventLabel [
	^'Git Cli Event'
]

{ #category : #accessing }
GtGitCliEvent >> args [
	^ self eventStartedSignal args
]

{ #category : #'gt - extensions' }
GtGitCliEvent >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Git call';
		priority: 5;
		items: [ 
			self eventCompletedSignal hasOutput
				ifTrue: [
					self args , #('' '=>' '') , self output ] 
				ifFalse: [ self args ] ]
]

{ #category : #accessing }
GtGitCliEvent >> output [
	^ self eventCompletedSignal output
]
