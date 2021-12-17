Class {
	#name : #LGitStatusOptions,
	#superclass : #LGitExternalObject,
	#instVars : [
		'statusOptionsVersion'
	],
	#category : #'GToolkit4Git-NonCoreObjects'
}

{ #category : #accessing }
LGitStatusOptions >> add: aStatusOptionsEnum [
	"TODO noop for now"
]

{ #category : #accessing }
LGitStatusOptions >> statusOptionsInit [
	statusOptionsVersion := 1.
	self status_options_init
]

{ #category : #accessing }
LGitStatusOptions >> status_options_init [
	self ffiCallSafely: #(int git_status_options_init(self, int statusOptionsVersion)) options: #()
]
